#!/usr/bin/env bash
set -e # Bail early
#set -x # Very verbose

sudo port install \
    apache-ant \
    autoconf \
    automake \
    bash \
    bison \
    ccache \
    clang-3.4 \
    cmake \
    git \
    glances \
    htop \
    jq \
    libtool \
    llvm-3.8 \
    lua \
    maven3 \
    mercurial \
    mutt \
    ncdu \
    pkgconfig \
    pstree \
    py27-pip \
    py27-virtualenv \
    python27 \
    the_silver_searcher \
    tmux \
    tree \
    vim \
    watch \
    wget

sudo port select --set maven maven3
sudo port select --set pip pip27

~/dotfiles/scripts/compileprotoc.sh

pip install --user --upgrade httpie
