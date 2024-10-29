#!/usr/bin/env bash
#set -e # Bail early
##set -x # Very verbose


echo "Installing regular apps."

brew install ncdu \
  dust \
  tldr \
  zellij \
  eza \
  htop \
  btop

echo "Installing casks."

brew install --cask slack spotify "visual-studio-code"


i
cargo install \
  jnv # interactive json explorer
