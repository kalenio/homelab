#!/bin/bash

# Navigate to vault
cd /home/xo/syncthing/repositories/Jörmungandr || exit

# Add changes to git
git add .

# Commit changes
git commit -m "Automated vault backup: $(date '+%Y-%m-%d %H:%M:%S')"

# Push changes to remote repo
# 'git branch -m main' to change branch name if initialized as something else.
git push origin main
