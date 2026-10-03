#!/bin/bash

# List files by git status, one path per line (relative to the current directory)
# Usage: gtls.sh [--tracked | --untracked | --staged | --unstaged]
#   --tracked    changed tracked files (default)
#   --untracked  untracked files
#   --staged     files with staged changes
#   --unstaged   files with unstaged modifications or deletions

if [[ $# -gt 1 ]]; then
    echo "You can specify only one of the following options: --tracked, --untracked, --staged, --unstaged" >&2
    exit 1
fi

mode="${1:---tracked}"
case "$mode" in
    --tracked|--staged|--unstaged) untracked="no" ;;
    --untracked)                   untracked="all" ;;
    *)
        echo "unrecognized option: $mode" >&2
        exit 1
        ;;
esac

# Short format: "XY <path>" or "XY <old> -> <new>" for renames/copies,
# paths with special characters are double-quoted.
git status --short --untracked-files="$untracked" |
    awk -v mode="$mode" '
        {
            x = substr($0, 1, 1)
            y = substr($0, 2, 1)
            path = substr($0, 4)
            if (path ~ / -> /) sub(/.* -> /, "", path)
            gsub(/^"|"$/, "", path)
        }
        mode == "--tracked"                    { print path }
        mode == "--untracked" && x == "?"      { print path }
        mode == "--staged"    && x != " "      { print path }
        mode == "--unstaged"  && y ~ /^[MD]$/  { print path }
    '
