#!/bin/bash
set -e

git -C "$HOME/setup" pull

projects_dir="$HOME/projetos"

if [ ! -d "$projects_dir" ]; then
  echo "projects directory does not exists. Run 'dot install' to create it." 
else
  echo "updating projects"

  for folder in "$projects_dir"/*; do
    echo -n "updating $(basename "$folder")..."
    if [ -d "$folder"/.git/ ]; then
      git -C "$folder" pull origin main --quiet
    fi
    echo "done."
  done
fi