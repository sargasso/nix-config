#!/usr/bin/env bash
nix-shell '<home-manager>' -A install

if [[ -e "${HOME}/.config/nixpkgs/home.nix ]]; then
  home-manager switch
fi

