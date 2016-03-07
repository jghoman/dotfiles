#!/usr/bin/env bash
set -e # Bail early
#set -x # Very verbose

if ! type  "protoc" > /dev/null; then
  echo "Fetching and compiling protoc"
  
  tempdir=`mktemp -d`
  pushd $tempdir

  cp ~/dotfiles/tgz/protobuf* .

  tar -xzvf *


  cd protobuf*
  ./configure
  make
  sudo make install

  popd
  rm -rf $tempdir
  
  echo "All done"

else
  echo "protoc already available. Not compiling."
fi
