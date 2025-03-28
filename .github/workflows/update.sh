#!/usr/bin/env bash

set -o pipefail

git remote set-head origin --auto
default_branch=$(git rev-parse --abbrev-ref origin/HEAD)

generate_body() {
  package="$1"
  re_from='^- +rev = "([0-9a-f]{40})"'
  re_to='^\+ +rev = "([0-9a-f]{40})"'
  while read -r line; do
    if [[ $line =~ $re_from ]]; then
      from=${BASH_REMATCH[1]}
    elif [[ $line =~ $re_to ]]; then
      to=${BASH_REMATCH[1]}
    fi
  done < <(git diff --unified=0 HEAD^..HEAD)
  if [ -n "$from" ] && [ -n "$to" ]; then
    compare="/compare/${from}...${to}"
  fi
  ./scripts/update -i "$package" | sed "/^Git: / s|\.git$|$compare|"
  echo "Log: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
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

  if [ "$(gh pr list --head "$update_branch" | wc -l)" -gt 0 ]; then
    echo "PR exists"
    git checkout "$update_branch"
    git clean -df
    if ! git merge-base --is-ancestor "$default_branch" "$update_branch"; then
      echo "New commits in $default_branch, reset and try to cherry-pick the PR"
      git reset --hard "$default_branch"
      git cherry-pick "origin/$update_branch" || git cherry-pick --abort
    fi
    if try_update "$package"; then
      echo "Upstream package is newer than the PR, reset to $default_branch and update again"
      git reset --hard "$default_branch"
      if try_update "$package"; then
        echo "::notice::$package: Update package succeeded, update PR"
        gh pr edit "$update_branch" --title "$(git show -s --format=%B)" --body "$(generate_body "$package")"
        git push --force origin "$update_branch"
      fi
    elif [ "$(git rev-parse HEAD)" = "$(git rev-parse "$default_branch")" ]; then
      echo "::notice::$package: Close, package already updated in $default_branch."
      git push --delete origin "$update_branch"
    elif [ "$(git rev-parse HEAD)" != "$(git rev-parse "origin/$update_branch")" ]; then
      echo "::notice::$package: Rebase to current $default_branch"
      git push --force origin "$update_branch"
    fi
  else
    echo "PR not exists"
    git checkout -B "$update_branch" "$default_branch"
    git clean -df
    if try_update "$package"; then
      echo "::notice::$package: Update package succeeded, create PR"
      git push --force origin "$update_branch"
      gh pr create --title "$(git show -s --format=%B)" --body "$(generate_body "$package")"
      echo "::notice::$package: Force push to trigger CI"
      git commit --amend --no-edit
      git push --force origin "$update_branch"
    fi
  fi

  echo "::endgroup::"
}

./scripts/update -la | while read -r package; do
  update_package "$package"
done
