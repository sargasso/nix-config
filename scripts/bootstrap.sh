#!/usr/bin/env bash

# Target release, see main system to keep in sync
RELEASE="21.05"

nix-channel --add https://github.com/nix-community/home-manager/archive/release-"${RELEASE}".tar.gz home-manager
nix-channel --update
nix-channel --list

