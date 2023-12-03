
{ config, lib, pkgs, ... }:
let
  tmuxconf = builtins.toFile "tmuxconf" ''
    set -g status off
    set -g destroy-unattached on
    set -g mouse on
    set -g default-terminal 'tmux-256color'
    set -ga terminal-overrides ',alacritty:RGB'
  '';
in
{

  programs.alacritty.enable = true;

  xdg.configFile."alacritty/alacritty.yml".text = ''
    live_config_reload: true
    cursor:
      style: Underline
    font:
      normal:
        family: FiraCode NerdFont Mono
        style: Medium
      bold:
        family: FiraCode NerdFont Mono
        style: Bold
      italic:
        family: FiraCode NerdFont Mono
        style: Italic
      bold_italic:
        family: FiraCode NerdFont Mono
        style: Bold
      size: 10
    window:
      dynamic_padding: true
      padding:
        x: 15
        y: 15
  '';

}
