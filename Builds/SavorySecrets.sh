#!/bin/sh
echo -ne '\033c\033]0;Savory Secrets\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/SavorySecrets.x86_64" "$@"
