{ lib, config, pkgs, ... }:
{
  fileSystems = lib.mkVMOverride {
    "/root/shared_dir" = {
        device = "host0_shared_dir";
        fsType = "9p";
        options = [ "trans=virtio" "version=9p2000.L" ];
    };
  };

  #services.tor.enable = true;
  #documentation.nixos.enable = false;
  services.nixosManual.enable = false;
  services.mingetty.autologinUser = "root";
  systemd.services."serial-getty@ttyS0".enable = true;
  networking.firewall.enable = false;

  # Should be required/used by the service.
  #services.postgresql.authentication
  #services.postgresql.extraConfig
  services.postgresql.enable = true;
  services.postgresql.port = 5432;
  #services.postgresql.initialScript

  #http://localhost:8080/guacamole
  # cat /var/tomcat/logs/catalina.2018-10-11.log
  # cat /var/tomcat/logs/localhost_access_log.2018-10-11.txt

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "yes";

  users = {

    mutableUsers = false;


    extraUsers = {

      root = {
        initialPassword = "root";
      };

      myuser = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
        ];
        uid = 1000;
        # Passord is: `pw`
        hashedPassword =
           "$6$uDyDrqyPYuvZFg$iG0uf3b6m/gw7VHaMGQOmff4j8gqTA69UTEx4fj.FlueWKQvxkEHrp9M8b87GF1dbnT2GWPjVb8gNRlsLDc9E1";

        packages = [
          # List suplementary packages available to this user.
        ];
      };
    };

  };

  i18n = {
    consoleKeyMap = "cf"; # Canadian french
    defaultLocale = "en_CA.UTF-8";
  };

  services.xserver = {
    enable = true;

    layout = "ca";
    xkbVariant = "fr";

    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };


  environment.systemPackages = with pkgs; [
    freerdp tigervnc x11vnc
    xorg.xmodmap
  ];
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.xfce.xfce4-session}/bin/xfce4-session";
  #services.xrdp.defaultWindowManager = "${pkgs.xfce.xfce4-session}/etc/xdg/xfce4/xinitrc";
  services.xrdp.extraKeymapFiles = {
    "km-00000c0c.ini" = ./custom_km_files/km-00000c0c.ini;
    "xrdp_keyboard.ini" = ./custom_km_files/xrdp_keyboard.ini;
  };
}