#!/bin/sh
printf '\033c\033]0;%s\a' DotDD
base_path="$(dirname "$(realpath "$0")")"
"$base_path/DDD.x86_64" "$@"
