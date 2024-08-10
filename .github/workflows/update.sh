#!/usr/bin/env bash

git remote set-head origin --auto
default_branch=$(git rev-parse --abbrev-ref origin/HEAD)

generate_body() {
  package="$1"
  compare=$(git show | awk -F'"' 'BEGIN {i=0} /^(-|+) +rev = "[0-9a-z]{40}"/ {a[i]=$2; i++} END {print a[0] "..." a[1]}')
  ./scripts/update -i "$package" | sed "/^Git: / s|\.git$|/compare/$compare|"
}

try_update() {
  package="$1"
  saved_commit=$(git rev-parse HEAD)
  ./scripts/update -c "$package" || true
  test "$(git rev-parse HEAD)" != "$saved_commit"
}

update_package() {
  package="$1"
  update_branch="update/$package"

  echo "::group::Update $package"

  if [ "$(gh pr list --head "$update_branch" | wc -l)" -gt 0 ]
  then
    echo "PR exists"
    git checkout "$update_branch"
    git clean -df
    if ! git merge-base --is-ancestor "$default_branch" "$update_branch"
    then
      git reset --hard "$default_branch"
      git cherry-pick "origin/$update_branch"
    fi
    if try_update "$package"
    then
      echo "Upstream newer than the PR, reset the branch and update again"
      git reset --hard "$default_branch"
      if try_update "$package"
      then
        echo "Update success, update the PR"
        gh pr edit "$update_branch" --title "$(git show -s --format=%B)" --body "$(generate_body "$package")"
      fi
    fi
    git push --force origin "$update_branch"
  else
    echo "PR not exists"
    git checkout -B "$update_branch" "$default_branch"
    git clean -df
    if try_update "$package"
    then
      echo "Update success, create PR"
      git push --force origin "$update_branch"
      gh pr create --title "$(git show -s --format=%B)" --body "$(generate_body "$package")"
    fi
  fi

  echo "::endgroup::"
}

./scripts/update -a -j | jq -r '.[].attrPath' | while read -r package
do
  update_package "$package"
done
