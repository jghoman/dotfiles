#!/usr/bin/env bash
set -e # Bail early
#set -x # Very verbose

sudo port install tmux vim git llvm-3.8 htop glances mutt bash  clang-3.4 the_silver_searcher maven3 tree ncdu

sudo port select --set maven maven3

