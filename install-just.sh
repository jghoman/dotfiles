#!/usr/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /tmp/just

echo "Just installed to /tmp - now use it run the rest of the installs via the justfile."
