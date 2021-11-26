
{ config, lib, pkgs, ... }:
let
  # Source: “境目” by 3211 on Pixiv: https://www.pixiv.net/en/artworks/39266182
  wallpaperUnfree = pkgs.fetchurl {
    name = "wallpaper-unfree";

    url = "https://i.pximg.net/img-original/img/2013/10/22/04/25/37/39266182_p0.jpg";
    sha256 = "053gc9jd4cbkkwgcirrhpzbn933dfh83l30p1sz55m5d8zx1lk65";
    curlOpts = "--referer https://pixiv.net";

    meta.license = lib.licenses.unfree;
  };
  wallpaperFree = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/swaywm/sway/3b2bc894a5ebbcbbd6707d45a25d171779c2e874/assets/Sway_Wallpaper_Blue_1920x1080.png";
    sha256 = "1rkqd0h7w64plibn7k3krk5vdc3pnv3fc7m2xc2mxnwrbsgngwsz";

    meta.license = lib.licenses.cc0;
  };
  wallpaper = wallpaperUnfree;

  cfg = config.wayland.windowManager.sway.config;
in
{
  imports = [
    ./waybar.nix
    ./gammastep.nix
  ];
  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "${pkgs.dmenu-wayland}/bin/dmenu-wl_path | ${pkgs.dmenu-wayland}/bin/dmenu-wl -nb '#002b36' -nf '#839496' -sb '#859900' -sf '#073642' | ${pkgs.findutils}/bin/xargs swaymsg exec --";
      output."*".bg = "${wallpaper} fill";

      keybindings = {
        # Basics
        "${cfg.modifier}+Return" = "exec ${cfg.terminal}";
        "${cfg.modifier}+Shift+q" = "kill";
        "${cfg.modifier}+p" = "exec ${cfg.menu}";
        "${cfg.modifier}+Control+r" = "reload";
        "${cfg.modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

        # Focus
        "${cfg.modifier}+${cfg.left}" = "focus left";
        "${cfg.modifier}+${cfg.down}" = "focus down";
        "${cfg.modifier}+${cfg.up}" = "focus up";
        "${cfg.modifier}+${cfg.right}" = "focus right";

        "${cfg.modifier}+Left" = "focus left";
        "${cfg.modifier}+Down" = "focus down";
        "${cfg.modifier}+Up" = "focus up";
        "${cfg.modifier}+Right" = "focus right";

        # Moving
        "${cfg.modifier}+Shift+${cfg.left}" = "move left";
        "${cfg.modifier}+Shift+${cfg.down}" = "move down";
        "${cfg.modifier}+Shift+${cfg.up}" = "move up";
        "${cfg.modifier}+Shift+${cfg.right}" = "move right";

        "${cfg.modifier}+Shift+Left" = "move left";
        "${cfg.modifier}+Shift+Down" = "move down";
        "${cfg.modifier}+Shift+Up" = "move up";
        "${cfg.modifier}+Shift+Right" = "move right";

        # Workspaces
        "${cfg.modifier}+1" = "workspace number 1";
        "${cfg.modifier}+2" = "workspace number 2";
        "${cfg.modifier}+3" = "workspace number 3";
        "${cfg.modifier}+4" = "workspace number 4";
        "${cfg.modifier}+5" = "workspace number 5";
        "${cfg.modifier}+6" = "workspace number 6";
        "${cfg.modifier}+7" = "workspace number 7";
        "${cfg.modifier}+8" = "workspace number 8";
        "${cfg.modifier}+9" = "workspace number 9";
        "${cfg.modifier}+0" = "workspace number 10";

        "${cfg.modifier}+Shift+1" = "move container to workspace number 1";
        "${cfg.modifier}+Shift+2" = "move container to workspace number 2";
        "${cfg.modifier}+Shift+3" = "move container to workspace number 3";
        "${cfg.modifier}+Shift+4" = "move container to workspace number 4";
        "${cfg.modifier}+Shift+5" = "move container to workspace number 5";
        "${cfg.modifier}+Shift+6" = "move container to workspace number 6";
        "${cfg.modifier}+Shift+7" = "move container to workspace number 7";
        "${cfg.modifier}+Shift+8" = "move container to workspace number 8";
        "${cfg.modifier}+Shift+9" = "move container to workspace number 9";
        "${cfg.modifier}+Shift+0" = "move container to workspace number 10";

        # Moving workspaces between outputs
        "${cfg.modifier}+Control+${cfg.left}" = "move workspace to output left";
        "${cfg.modifier}+Control+${cfg.down}" = "move workspace to output down";
        "${cfg.modifier}+Control+${cfg.up}" = "move workspace to output up";
        "${cfg.modifier}+Control+${cfg.right}" = "move workspace to output right";

        "${cfg.modifier}+Control+Left" = "move workspace to output left";
        "${cfg.modifier}+Control+Down" = "move workspace to output down";
        "${cfg.modifier}+Control+Up" = "move workspace to output up";
        "${cfg.modifier}+Control+Right" = "move workspace to output right";

        # Splits
        "${cfg.modifier}+b" = "splith";
        "${cfg.modifier}+v" = "splitv";

        # Layouts
        "${cfg.modifier}+s" = "layout stacking";
        "${cfg.modifier}+t" = "layout tabbed";
        "${cfg.modifier}+e" = "layout toggle split";
        "${cfg.modifier}+Shift+m" = "fullscreen toggle";

        "${cfg.modifier}+a" = "focus parent";

        "${cfg.modifier}+Control+space" = "floating toggle";
        "${cfg.modifier}+space" = "focus mode_toggle";

        # Scratchpad
        "${cfg.modifier}+Shift+minus" = "move scratchpad";
        "${cfg.modifier}+minus" = "scratchpad show";

        # Resize mode
        "${cfg.modifier}+d" = "mode resize";

        # Multimedia Keys
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "--locked XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "--locked XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";

        "XF86AudioPrev" = "exec ${pkgs.mpc_cli}/bin/mpc -q next";
        "XF86AudioNext" = "exec ${pkgs.mpc_cli}/bin/mpc -q prev";
        "XF86AudioPlay" = "exec ${pkgs.mpc_cli}/bin/mpc -q toggle";
        "XF86AudioPause" = "exec ${pkgs.mpc_cli}/bin/mpc -q toggle";

        # Locking and DPMS
        "${cfg.modifier}+y" = "exec ${pkgs.swaylock}/bin/swaylock -f -i ${wallpaper}";
        "--no-repeat --locked ${cfg.modifier}+q" = ''exec 'test $(swaymsg -t get_outputs | ${pkgs.jq}/bin/jq "[.[].dpms] | any") = "true" && swaymsg "output * dpms off" || swaymsg "output * dpms on"'';
      };

      bars = [ ]; # managed as systemd user unit

      assigns = {
        "2" = [
          { app_id = "firefox"; }
          { class="Chromium"; }
        ];
        "3" = [
          { class = "Claws-mail"; }
        ];
        "4" = [
          { app_id = "anki"; }
          { app_id = "libreoffice-startcenter"; }
          { app_id = "net.sourceforge.gscan2pdf"; }
          { app_id = "org.pwmt.zathura"; }
          { app_id = "xournalpp"; }
        ];
        "5" = [
          { app_id = "audacious"; }
          { app_id = "pavucontrol"; }
        ];
        "8" = [
          { app_id = "darktable"; }
          { app_id = "org.inkscape.Inkscape"; }
          { class = "Blender"; }
          { class = "Gimp"; }
          { class = "krita"; }
        ];
      };

      window.border = 1;

      floating = {
        titlebar = true;
        border = 1;
      };

      colors = {
        focused = rec { border = "#93a1a1"; background = "#073642"; text = "#93a1a1"; indicator = "#2aa198"; childBorder = background; };
        focusedInactive = rec { border = "#839496"; background = "#002b36"; text = "#839496"; indicator = "#2aa198"; childBorder = background; };
        unfocused = rec { border = "#839496"; background = "#002b36"; text = "#839496"; indicator = "#2aa198"; childBorder = background; };
        urgent = rec { border = "#073642"; background = "#dc322f"; text = "#073642"; indicator = "#2aa198"; childBorder = background; };
      };

      fonts = {
        names = [ "monospace" ];
        style = "Regular";
        size = 10.0;
      };
    };

    extraConfig = ''
      # Cursor
      seat seat0 xcursor_theme Adwaita
    '' + (
      let
        environmentVariables = lib.concatStringsSep " " [
          "DBUS_SESSION_BUS_ADDRESS"
          "DISPLAY"
          "SWAYSOCK"
          "WAYLAND_DISPLAY"
        ];
      in
      ''
        # From https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start
        exec systemctl --user import-environment ${environmentVariables} && \
          hash dbus-update-activation-environment 2>/dev/null && \
          dbus-update-activation-environment --systemd ${environmentVariables} && \
          systemctl --user start sway-session.target
      ''
    );
  };

  systemd.user.targets.sway-session = {
    Unit = {
      Description = "sway compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.services.swayidle = {
    Unit.PartOf = [ "sway-session.target" ];
    Install.WantedBy = [ "sway-session.target" ];

    Service = {
      # swayidle requires sh and swaymsg to be in path
      Environment = "PATH=${pkgs.bash}/bin:${config.wayland.windowManager.sway.package}/bin";
      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 300 "${pkgs.swaylock}/bin/swaylock -f -i ${wallpaper}" \
            timeout 300 'swaymsg "output * dpms off"' \
                resume 'swaymsg "output * dpms on"' \
            before-sleep "${pkgs.swaylock}/bin/swaylock -f -i ${wallpaper}"
      '';
      Restart = "on-failure";
    };
  };

  xdg.configFile."swaynag/config".text =
    let
      # adding it to the header doesn’t work since the defaults overwrite it
      commonConfig = /* ini */ ''
        background=fdf6e3
        border-bottom=eee8d5
        border=eee8d5
        button-background=fdf6e3
        button-text=657b83
      '';
    in
      /* ini */ ''
      font=Monospace 12

      [warning]
      text=b58900
      ${commonConfig}

      [error]
      text=dc322f
      ${commonConfig}
    '';

  home.sessionVariables = {
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland";
    GDK_DPI_SCALE = 1;
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland-egl";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    SDL_VIDEODRIVER = "wayland";
    WLR_NO_HARDWARE_CURSORS = 1;
    _JAVA_AWT_WM_NONREPARENTING = 1;
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";
  };

  home.packages = with pkgs; [
    alacritty # terminal
    brightnessctl # control screen brightness
    sway-contrib.grimshot # screenshots
    wdisplays # graphical output manager
    waybar
    gammastep
  ];
}

