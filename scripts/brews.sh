#!/usr/bin/env bash
set -e # Bail early
#set -x # Very verbose

for c in slack intellij-idea spotify visual-studio-code java8 java
do
  brew cask install $c
done
