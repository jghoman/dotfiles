#!/usr/bin/env bash

printf "\nif [ -f ~/.my_bash_profile ]; then\n  . ~/.my_bash_profile\nfi\n\n" >> ~/.bashrc
