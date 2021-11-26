{ config, lib, pkgs, ... }:
let
  watchUserUnitState = unit: started: stopped: pkgs.writeShellScript "watch-user-unit-${unit}-state" ''
    ${pkgs.systemd}/bin/journalctl --user -u ${unit} -t systemd -o cat -f \
        | ${pkgs.gnugrep}/bin/grep --line-buffered -Eo '^(Started|Stopped)' \
        | ${pkgs.jq}/bin/jq --unbuffered -Rc 'if . == "Started" then ${builtins.toJSON started} else ${builtins.toJSON stopped} end'
  '';

  toggleUserUnitState = unit: pkgs.writeShellScript "toggle-user-unit-${unit}-state" ''
    if ${pkgs.systemd}/bin/systemctl --user show ${unit} | ${pkgs.gnugrep}/bin/grep -q ActiveState=active; then
        ${pkgs.systemd}/bin/systemctl --user stop ${unit}
    else
        ${pkgs.systemd}/bin/systemctl --user start ${unit}
    fi
  '';

  # nerd fonts are abusing arabic which breaks latin text
  # context: https://github.com/Alexays/Waybar/issues/628
  lrm = "&#8206;";

  # for fine-grained control over spacing
  thinsp = "&#8201;";

  common = import ../common.nix;
  colors = common.colorschemes.solarized;
in
{
  # home-manager’s waybar module performs additional checks that are overly strict
  xdg.configFile."waybar/config".text = lib.generators.toJSON { } {
    layer = "top";
    position = "top";
    height = 24;

    modules-center = [ ];
    modules-left = [
      "sway/workspaces"
      "sway/mode"
    ];
    modules-right = [
      "tray"
      "custom/screencast"
      "custom/redshift"
      "idle_inhibitor"
      "backlight"
      "mpd"
      "pulseaudio"
      "network"
      "custom/vpn"
      "memory"
      "cpu"
      "temperature"
      "battery"
      "clock"
      "custom/calendar"
    ];

    "sway/workspaces" = {
      disable-scroll = true;
    };
    "sway/mode" = {
      format = "{}";
    };

    tray = {
      spacing = 5;
    };
    "custom/redshift" = {
      exec = watchUserUnitState
        "gammastep"
        { class = "active"; }
        { class = "inactive"; };
      on-click = toggleUserUnitState "gammastep";
      return-type = "json";
      format = "";
      tooltip = false;
    };
    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = " ";
        deactivated = " ";
      };
    };
    backlight = {
      format = "{percent}% {icon}";
      format-icons = [ " " " " " " " " " " " " " " ];
      on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl -q set +5%";
      on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl -q set 5%-";
    };
    mpd = {
      server = config.services.mpd.network.listenAddress;
      format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} – {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ";
      format-disconnected = "Disconnected ";
      format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
      unknown-tag = "N/A";
      interval = 2;
      tooltip-format = "MPD (connected)";
      tooltip-format-disconnected = "MPD (disconnected)";
      on-scroll-up = "${pkgs.mpc_cli}/bin/mpc -q -h ${config.services.mpd.network.listenAddress} volume +2";
      on-scroll-down = "${pkgs.mpc_cli}/bin/mpc -q -h ${config.services.mpd.network.listenAddress} volume -2";
      title-len = 48;
      artist-len = 24;
      consume-icons = {
        on = " ";
      };
      random-icons = {
        off = "劣 ";
        on = "列 ";
      };
      repeat-icons = {
        on = "凌 ";
      };
      single-icons = {
        on = "綾 ";
      };
      state-icons = {
        paused = "";
        playing = "契";
      };
    };
    pulseaudio = {
      format = "{volume}% {icon} {format_source}";
      format-bluetooth = "{volume}% {icon} {format_source}";
      format-bluetooth-muted = "${lrm}ﱝ${lrm}  {icon} {format_source}";
      format-muted = "${lrm}ﱝ${lrm}  {format_source}";
      format-source = "{volume}% ${thinsp}";
      format-source-muted = "${thinsp}";
      format-icons = {
        car = " ";
        default = [ "奄" "奔" "墳" ];
        hands-free = " ";
        headphone = " ";
        headset = " ";
        phone = " ";
        portable = " ";
      };
      on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
    };
    network = {
      format-wifi = "{essid} ({signalStrength}%) 直 ";
      format-ethernet = "{ipaddr}/{cidr}  ";
      format-linked = "{ifname} (No IP)  ";
      format-disconnected = "Disconnected ⚠ ";
      format-alt = "{ifname}: {ipaddr}/{cidr}";
      tooltip = false;
      on-click-right = "${config.programs.alacritty.package}/bin/alacritty -e ${pkgs.networkmanager}/bin/nmtui";
    };
    "custom/vpn" = {
      interval = 10;
      exec = pkgs.writeShellScript "vpn-state" ''
        ${pkgs.iproute}/bin/ip -j link \
          | ${pkgs.jq}/bin/jq --unbuffered --compact-output '
            [[.[].ifname | select(. | startswith("mullvad"))][] | split("-")[1] + " ${thinsp}"] as $conns
            | { text: ($conns[0] // ""), class: (if $conns | length > 0 then "connected" else "disconnected" end) }'
      '';
      return-type = "json";
      format = "{}";
      tooltip = false;
    };
    memory = {
      interval = 2;
      format = "{:2}%  ";
    };
    cpu = {
      interval = 2;
      format = "{usage:2}% ﬙ ";
      tooltip = false;
    };
    temperature = {
      critical-threshold = 80;
      format = "{temperatureC}°C {icon}";
      format-icons = [ "" "" "" "" "" ];
      hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
    };
    battery = {
      interval = 5;
      format = "{capacity}% {icon}";
      format-charging = "{capacity}% ";
      format-plugged = "{capacity}% ${lrm}ﮣ";
      format-alt = "{time} {icon}";
      format-icons = [ "" "" "" "" "" "" "" "" "" "" "" ];
      states = {
        critical = 15;
        good = 95;
        warning = 30;
      };
    };
    clock = {
      format = "{:%H:%M %Z}";
      format-alt = "{:%Y-%m-%d (%a)}";
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
    };
    "custom/calendar" = {
      interval = 300;
      exec = pkgs.writeScript "calendar" /* python */ ''
        #!${pkgs.python3}/bin/python3
        import json
        import subprocess


        def khal(args):
            completed = subprocess.run(["${pkgs.khal}/bin/khal"] + args, capture_output=True)
            assert completed.returncode == 0
            return completed.stdout.decode("utf-8")


        events_today = khal(["list", "today", "today", "-df", "", "-f", "{title}"]).rstrip().split("\n")
        events_2d = khal(["list", "today", "tomorrow", "-df", "<b>{name}, {date}</b>"]).rstrip()

        if len(events_today) == 1 and events_today[0] == "No events":
            events_today = []

        if len(events_today) == 0:
            text = " "
        else:
            text = f"{len(events_today)}  "

        print(
            json.dumps(
                {
                    "class": "active" if len(events_today) > 0 else "",
                    "text": text,
                    "tooltip": events_2d,
                }
            )
        )
      '';
      return-type = "json";
      format = "{}";
    };
  };

  xdg.configFile."waybar/style.css".source = pkgs.substituteAll ({
    src = ./waybar.css;
  } // (import ./common.nix).colorschemes.solarized);

  systemd.user.services.waybar = {
    Unit = {
      Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      Documentation = "https://github.com/Alexays/Waybar/wiki/";
      PartOf = [ "sway-session.target" ];
    };

    Install.WantedBy = [ "sway-session.target" ];

    Service = {
      # ensure sway is already started, otherwise workspaces will not work
      ExecStartPre = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
      ExecStart = "${pkgs.waybar}/bin/waybar";
      ExecReload = "${pkgs.utillinux}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      RestartSec = "1s";
    };
  };

  # TODO: remove when https://github.com/nix-community/home-manager/issues/2064
  # is resolved
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
}

