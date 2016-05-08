#!/usr/bin/env bash
set -e # Bail early
#set -x # Very verbose

mkdir -p ~/.config/fish
ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
