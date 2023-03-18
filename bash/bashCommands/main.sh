#!/bin/bash

# custom function to enter specific directroy.
function cdJump(){
  local target=$1
  local dir=$(find . -type d -name "$target" -not -path '*/\.*' -not -path '*/lvim/*' -not -path '*/neovim/*' -not -path '*/node_modules/*' | head -n 1 )
  if [[ -n "$dir" ]]; then
    cd "$dir"
  else
    echo "NOT FOUND: $target"
  fi
}

# git commands
function gitUp(){
  local msg="$1"
  local branch="$2"
  git add .
  git commit -S -am "$msg"
  git push origin $branch 
}

# setting the cron jobs for +i attibute 
function attiSet(){
     chattr +i ~//*
     chattr -i ~/Downloads
}

attiSet > /tmp/attiSet.log 2>&1 &

# adding lvim default editor
export VISUAL=lvim
export EDITOR="$VISUAL"


