#!/bin/bash

# custom function to enter specific directroy.
function cdJump(){
  local target=$1
  local cashFile=".cdjump_cash.txt"
  local history_file="$HOME/$cashFile"
  
  local dir=$(grep -i "$target" "$history_file" | head -n 1)

  if [[ -n "$dir" ]]; then
    cd "$dir"
  else
    dir=$(find . -type d -iname "$target" -not -path '*/\.*' -not -path '*/lvim/*' -not -path '*/neovim/*' -not -path '*/node_modules/*' | head -n 1 )
    if [[ -n "$dir" ]]; then
        echo "$dir" >> "$cashFile" 
        cd "$dir"
    else
      echo "NOT FOUND: $target"
    fi
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
     chmod 755 ~/*
}

attiSet > /tmp/attiSet.log 2>&1 &

# adding lvim default editor
export VISUAL=lvim
export EDITOR="$VISUAL"




