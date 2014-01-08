#!/usr/bin/env bash
set -e

# Yeah, this could be a lot more elegant. But somehow that would seem to be an insult to BASH.
 
link_file () {
  DESTFILE=$1
  SOURCEDIR=$2
  if [ -e ~/$DESTFILE ]; then
    echo "Remove existing ln and replace for $DESTFILE?"
    read remove
    if [ "$remove" == "y" ]; then
      rm ~/$DESTFILE
      PROCEED="YES"
    else
      PROCEED="NO"
    fi
  else
    PROCEED="YES"
  fi

  if [ "$PROCEED" == "YES" ]; then
    ln -s ~/config-files/$SOURCEDIR/$DESTFILE ~/$DESTFILE
  fi
}

link_file ".gitconfig" "git"
link_file ".tmux.conf" "tmux"
