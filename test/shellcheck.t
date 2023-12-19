#!/usr/bin/env bash

source test/setup

use Test::More

d="[[:digit:]]"
if [[ $(shellcheck --version) =~ ($d+)\.($d+)\.($d+) ]]; then
  if [[ ${BASH_REMATCH[1]} -eq 0 ]]; then
    if [[ ${BASH_REMATCH[2]} -eq 7 ]] && [[ ${BASH_REMATCH[3]} -lt 1 ]] ||
       [[ ${BASH_REMATCH[2]} -lt 7 ]]; then
      plan skip_all "This test requires at least shellcheck version 0.7.1"
    fi
  fi
else
  plan skip_all "The 'shellcheck' utility is not installed or version can't be detected."
fi

IFS=$'\n' read -d '' -r -a shell_files <<< "$(
  echo .rc
  find lib -type f
  echo test/setup
  find test -name '*.t'
  echo share/enable-completion.sh
)" || true

skips=(
  # We want to keep these 2 here always:
  SC1090  # Can't follow non-constant source. Use a directive to specify location.
  SC1091  # Not following: bash+ was not specified as input (see shellcheck -x).
)
skip=$(IFS=,; echo "${skips[*]}")

for file in "${shell_files[@]}"; do
  [[ $file == *swp ]] && continue
  is "$(shellcheck -e "$skip" "$file")" "" \
    "The shell file '$file' passes shellcheck"
done

done_testing

# vim: set ft=sh:
