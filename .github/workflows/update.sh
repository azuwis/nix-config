#!/usr/bin/env bash

git remote set-head origin --auto
default_branch=$(git rev-parse --abbrev-ref origin/HEAD)

update_package() {
  package="$1"
  update_branch="update/$package"

  if [ "$(gh pr list --head "$update_branch" | wc -l)" -gt 0 ]
  then
    # PR exists
    git checkout "$update_branch"
    git clean -df
    if ! git merge-base --is-ancestor "$default_branch" "$update_branch"
    then
      git reset --hard "$default_branch"
      git cherry-pick "origin/$update_branch"
    fi
    saved_commit=$(git rev-parse HEAD)
    ./scripts/update -c "$package" || true
    if [ "$(git rev-parse HEAD)" != "$saved_commit" ]
    then
      # Upstream newer than the PR, reset the branch and update again
      git reset --hard "$default_branch"
      if ./scripts/update -c "$package"
      then
        # Update success, update the PR
        gh pr edit "$update_branch" --title "$(git show -s --format=%B)"
      fi
    fi
    git push --force origin "$update_branch"
  else
    # PR not exists
    git checkout -B "$update_branch" "$default_branch"
    git clean -df
    ./scripts/update -c "$package" || true
    if [ "$(git rev-list --count "${default_branch}..")" -gt 0 ]
    then
      # Update success, create PR
      git push --force origin "$update_branch"
      gh pr create --fill
    fi
  fi
}

./scripts/update -a -j | jq -r '.[].attrPath' | while read -r package
do
  update_package "$package"
done
