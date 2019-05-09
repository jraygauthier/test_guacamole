{ lib, config, pkgs, ... }:
{
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




  /*

  ```bash
  $ nix-shell -p freerdp -p tigervnc -p x11vnc
  ```

  ```bash
  $ xfreerdp /u:root /p:root /v:localhost:3389
  $ xfreerdp /u:myuser /p:pw /v:localhost:3389
  $ xfreerdp /u:myuser /p:pw /v:localhost:3389 /w:640 /h:480 /bpp:8
  $ xfreerdp /u:myuser /p:pw /v:localhost:3389 /w:640 /h:480 /bpp:8 /monitors:[0]
  ```

  really does show me an xfce session.


  Using `export QEMU_OPTS="-vnc :1 -nographic` option, the following work fine on the host:

  ```bash
  $ vncviewer localhost:1
  ```

  See more qemu vnc security options:

   -  [Suse Doc: Virtualization with KVM - Viewing a VM Guest with VNC - September 28 2013](https://www.suse.com/documentation/sles11/book_kvm/data/cha_qemu_running_vnc.html)

  */

  environment.systemPackages = with pkgs; [
    freerdp tigervnc x11vnc
    xorg.xmodmap
  ];
  services.xrdp.enable = true;
  #services.xrdp.package = pkgs.freerdpUnstable;
  #services.xrdp.port = 3389
  #services.xrdp.defaultWindowManager = "${pkgs.xterm}/bin/xterm";

  services.xrdp.defaultWindowManager = "${pkgs.xfce.xfce4-session}/bin/xfce4-session";
  #services.xrdp.defaultWindowManager = "${pkgs.xfce.xfce4-session}/etc/xdg/xfce4/xinitrc";
  #networking.firewall.allowedTCPPorts = [ 3389 ];

  /*
  French canadian keyboard does not work.
   -  [[GUACAMOLE-607] RDP French Canadian - ASF JIRA](https://issues.apache.org/jira/browse/GUACAMOLE-607)

  It does not work either using rdp, vnc or even ssh.

  However it works well in graphical qmu (through its own vnc), but it doesn't using `vncviewer localhost:1`.

  ```bash
  $ xfreerdp /kbd-list
  $ xfreerdp /u:myuser /v:localhost:3389 /kbd:0x00000C0C
  ```

  ```bash
  $ nix-shell -I "$HOME/dev/nixpkgs_root" -p xrdp
  $ which xrdp | xargs dirname | xargs thunar
  ```

   -  [[ubuntu] XRDP keyboad settings](https://ubuntuforums.org/showthread.php?t=2071308)

      Some commands to generate supplementary layouts.


   -  [xrdp - how to change keyboard layout - Ask Ubuntu](https://askubuntu.com/questions/412755/xrdp-how-to-change-keyboard-layout)


       -  [rdesktop / Code / [r1704] /rdesktop/trunk/doc/keymap-names.txt](https://sourceforge.net/p/rdesktop/code/1704/tree/rdesktop/trunk/doc/keymap-names.txt)

          `0x0C0C fr-ca French (Canada)`

  ```bash
  $ `which xrdp | xargs dirname | xargs dirname`/sbin/xrdp-genkeymap km-00000c0c.ini
  $ meld km-out.ini /nix/store/pkb3y86xlrzr8qw43wxry447z9p9v684-xrdp-0.9.7/etc/xrdp/km-0000040c.ini

  $ mkdir ../xrdp_cfg && cp -r -t ../xrdp_cfg/ /nix/store/pkb3y86xlrzr8qw43wxry447z9p9v684-xrdp-0.9.7/etc/xrdp/*.*
  $ `which xrdp | xargs dirname | xargs dirname`/sbin/xrdp-genkeymap ../xrdp_cfg/km-00000c0c.ini
  $ xrdp-keygen xrdp ../xrdp_cfg/rsakeys.ini
  ```

  ```bash
  $ sudo xrdp -n --config $HOME/dev/xrdp_cfg/xrdp.ini
  # ...
  [20181019-21:27:24] [INFO ] Loading keymap file /home/rgauthier/dev/xrdp_cfg/km-00000c0c.ini
  [20181019-21:27:24] [WARN ] local keymap file for 0x00000c0c found and doesn't match built in keymap, using local keymap file
  # ...
  ```

  ```bash
  $ sudo xrdp-sesman --nodaemon --config $HOME/dev/xrdp_cfg/sesman.ini
  [20181019-21:37:00] [INFO ] A connection received from ::ffff:127.0.0.1 port 46824
  pam_authenticate failed: Authentication failure
  [20181019-21:37:00] [DEBUG] Closed socket 8 (AF_INET6 ::ffff:127.0.0.1 port 3350)
  ```

   -  [[GUACAMOLE-352] Add support for dead keys - ASF JIRA](https://issues.apache.org/jira/browse/GUACAMOLE-352)

      Seems that it should only work in upcoming V1.

      This is what explains our issues with ssh session. The keymap is correct but for
      the dead keys. This is a front end issue.

   -  [XRDP Devel - [Xrdp-devel] alt+gr key not working for german keyboard](http://xrdp-devel.766250.n3.nabble.com/Xrdp-devel-alt-gr-key-not-working-for-german-keyboard-td4025717.html)

      With the special keymap file, when entering
      the session, simply typeing `setxkbmap ca` in
      a terminal makes the keyboard work fine using xfreerdp client. It however does not
      work at all using guacamole.




   -  [[GUACAMOLE-233] Add Spanish keymap for RDP - ASF JIRA](https://issues.apache.org/jira/browse/GUACAMOLE-233)

   -  [[GUAC-1362] Special characters via XRDP / German keyboard layout / Keyboard translation - Glyptodon, Inc. JIRA](https://jira.glyptodon.org/browse/GUAC-1362?jql=text%20~%20%22layout%22)

   -  [[GUAC-208] xrdp german keyboard layout - Glyptodon, Inc. JIRA](https://jira.glyptodon.org/browse/GUAC-208?jql=text%20~%20%22layout%22)

   -  [[GUAC-1192] x11rdp connections cannot use capslock or control keys. - Glyptodon, Inc. JIRA](https://jira.glyptodon.org/browse/GUAC-1192?jql=text%20~%20%22layout%22)

   -  [[GUAC-659] Not all keys work on non-US keyboards - Glyptodon, Inc. JIRA](https://jira.glyptodon.org/browse/GUAC-659?jql=text%20~%20%22layout%22)


  > qemu-system-x86_64: warning: no scancode found for keysym 233

   -  [Bug 1503128 – update reverse keymaps for qemu vnc server](https://bugzilla.redhat.com/show_bug.cgi?id=1503128)


  It seems that guacamole rdp only builds with the legacy 1.2 freerdp client. It won't work with
  the V2.0.

   -  [[GUACAMOLE-249] Update RDP plugin support to 2.0.0 releases - ASF JIRA](https://issues.apache.org/jira/browse/GUACAMOLE-249?jql=text%20~%20%22freerdp%22)


  It seems that xrdp does not support *Unicode events*:

   -  [Parallels Client is not able to RDP to xRDP · Issue #439 · neutrinolabs/xrdp](https://github.com/neutrinolabs/xrdp/issues/439#issuecomment-253577643)

   -  [[GUAC-1362] Special characters via XRDP / German keyboard layout / Keyboard translation - Glyptodon, Inc. JIRA](https://jira.glyptodon.org/browse/GUAC-1362)

   -  [Issues · neutrinolabs/xrdp](https://github.com/neutrinolabs/xrdp/issues?utf8=%E2%9C%93&q=is%3Aissue+unicode)

   -  [Releases · neutrinolabs/xrdp](https://github.com/neutrinolabs/xrdp/releases)

      V0.9.8 is release. Nixpkgs at 0.9.7.

  Guacamole does not have a fr-ca key map for rdp.


   -  [guacamole-server/src/protocols/rdp/keymaps at master · apache/guacamole-server](https://github.com/apache/guacamole-server/tree/master/src/protocols/rdp/keymaps)

       -  [guacamole-server/fr_ch_qwertz.keymap at master · apache/guacamole-server](https://github.com/apache/guacamole-server/blob/master/src/protocols/rdp/keymaps/fr_ch_qwertz.keymap)

          Inspiration.

  */





  /*
  Tomcat currently uses port 8080 which can conflict with other apps.
  Will have to add the feature to `nixos/modules/services/web-servers/tomcat.nix`
  as it is not yet available. See the following snipet:

  ```
    -->
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    <!-- A "Connector" using the shared thread pool-->
    <!--
    <Connector executor="tomcatThreadPool"
               port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
  ```
  */

  services.guacamole.enable = true;

  services.guacamole.propertiesText = ''
    auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
    guacd-hostname: localhost
    guacd-port: 4822
    enable-websocket: true
  '';

/*
  services.guacamole.propertiesExtraText = ''
    #postgresql-hostname: localhost
    #postgresql-port: 5432
    #postgresql-database: guacamole_db
    #postgresql-username: guacamole_user
    #postgresql-password: changeme
    #postgresql-default-max-connections: 1
    #postgresql-default-max-group-connections: 1
  '';
*/
  #services.guacamole.propertiesFile = "${pkgs.bash}/bin/my_file.txt";

  #services.guacamole.userMappingFile = "${pkgs.bash}/bin/my_file.txt";

  /*
    Generate hashed password using:

     -  encoding="sha512"

        `mkpasswd -m sha-512` -> does not work.

        ```bash
        $ echo -n "pw" | sha512sum`
        be196838736ddfd0007dd8b2e8f46f22d440d4c5959925cb49135abc9cdb01e84961aa43dd0ddb6ee59975eb649280d9f44088840af37451828a6412b9b574fc
        ```

        -> no, still does not work.

     -  encoding="md5"

        `mkpasswd -m md5` -> does not work.

        ```bash
        $ echo -n "pw" | md5sum
        8fe4c11451281c094a6578e6ddbf5eed
        ```
        -> ok, works.


  */
  services.guacamole.userMappingText = ''
    <user-mapping>
        <authorize
            username="user"
            password="8fe4c11451281c094a6578e6ddbf5eed"
            encoding="md5">
    	    <connection name="ssh - root">
              <protocol>ssh</protocol>
              <param name="username">root</param>
              <param name="hostname">localhost</param>
              <param name="port">22</param>
          </connection>
          <connection name="rdp - myuser">
              <protocol>rdp</protocol>
              <param name="security">any</param>
              <param name="username">myuser</param>
              <param name="password">pw</param>
              <param name="hostname">localhost</param>
              <param name="port">3389</param>
              <param name="server-layout">en-ca-qwerty</param>
              <param name="ignore-cert">true</param>
          </connection>
          <connection name="rdp - on host - en-ca-qwerty">
              <protocol>rdp</protocol>
              <param name="security">any</param>
              <param name="hostname">10.0.2.2</param>
              <param name="port">3389</param>
              <param name="server-layout">en-ca-qwerty</param>
              <param name="ignore-cert">true</param>
          </connection>
          <connection name="rdp - on host - failsafe">
              <protocol>rdp</protocol>
              <param name="security">any</param>
              <param name="hostname">10.0.2.2</param>
              <param name="port">3389</param>
              <param name="server-layout">failsafe</param>
              <param name="ignore-cert">true</param>
          </connection>
          <connection name="rdp - on host - fr-ca-qwerty">
              <protocol>rdp</protocol>
              <param name="security">any</param>
              <param name="hostname">10.0.2.2</param>
              <param name="port">3389</param>
              <param name="server-layout">fr-ca-qwerty</param>
              <param name="ignore-cert">true</param>
          </connection>
          <connection name="rdp - myuser - lowres">
              <protocol>rdp</protocol>
              <param name="security">any</param>
              <param name="username">myuser</param>
              <param name="password">pw</param>
              <param name="hostname">localhost</param>
              <param name="port">3389</param>
              <param name="server-layout">failsafe</param>
              <param name="ignore-cert">true</param>
              <param name="color-depth">8</param>
              <param name="width">640</param>
              <param name="height">480</param>
              <param name="enable-wallpaper">true</param>
          </connection>
          <connection name="vnc - myuser">
              <protocol>vnc</protocol>
              <param name="username">myuser</param>
              <param name="password">pw</param>
              <param name="hostname">10.0.2.2</param>
              <param name="port">5901</param>
          </connection>
        </authorize>
    </user-mapping>
  '';
}

/*
      # TODO: postgress default setup:
      #  -  [HowTo Setup Guacamole - NST Wiki](http://wiki.networksecuritytoolkit.org/index.php/HowTo_Setup_Guacamole)
      #  -  [Chapter 6. Database authentication](https://guacamole.apache.org/doc/gug/jdbc-auth.html)

 -  [Chapter 5. Configuring Guacamole](https://guacamole.apache.org/doc/gug/configuring-guacamole.html#rdp)
 -  [Setting Up Web-Based Guacamole Tool to Access Remote Linux/Windows Machines](https://www.tecmint.com/guacamole-access-remote-linux-windows-machines-via-web-browser/)

*/

/*
  By default I get:
  ```bash
  $ cat /var/tomcat/logs/localhost_access_log.2018-10-11.txt
  10.0.2.2 - - [11/Oct/2018:04:48:57 +0000] "GET /guacamole HTTP/1.1" 404 -
  ```

  This can be fixed by copying guacamole to the proper location:
  ```bash
  $ cp -p /var/tomcat/webapps/shbisdarfdhwcm4b66jk64r7czjfzf21-guacamole-0.9.14.war /var/tomcat/webapps/guacamole.war
  ```

  However this is not all as I now still received an all blank html and looking at logs now has:

  ```bash
  $ cat /var/tomcat/logs/localhost_access_log.2018-10-11.txt
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole HTTP/1.1" 302 -
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/ HTTP/1.1" 200 4442
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/relocateParameters.js HTTP/1.1" 200 4505
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/angular-cookies/1.3.16/angular-cookies.min.js HTTP/1.1" 200 865
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/angular-route/1.3.16/angular-route.min.js HTTP/1.1" 200 4409
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/jquery/2.1.3/dist/jquery.min.js HTTP/1.1" 200 84447
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/angular-translate-interpolation-messageformat/2.8.0/angular-translate-interpolation-messageformat.min.js HTTP/1.1" 200 1277
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/angular-translate/2.8.0/angular-translate.min.js HTTP/1.1" 200 20251
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/angular-translate-loader-static-files/2.8.0/angular-translate-loader-static-files.min.js HTTP/1.1" 200 1353
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/blob-polyfill/1.0.20150320/Blob.js HTTP/1.1" 200 6148
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/angular-touch/1.3.16/angular-touch.min.js HTTP/1.1" 200 3608
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/filesaver/1.3.3/FileSaver.min.js HTTP/1.1" 200 2446
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/angular/1.3.16/angular.min.js HTTP/1.1" 200 126532
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/app.css?v=0.9.14 HTTP/1.1" 200 48991
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/angular-module-shim/0.0.4/angular-module-shim.js HTTP/1.1" 200 774
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/lodash/2.4.1/dist/lodash.min.js HTTP/1.1" 200 28187
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/webjars/messageformat/1.0.2/messageformat.min.js HTTP/1.1" 200 49339
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/app.js?v=0.9.14 HTTP/1.1" 200 298765
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/fonts/carlito/Carlito-Regular.woff HTTP/1.1" 200 269832
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/images/logo-144.png HTTP/1.1" 200 9167
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/images/logo-64.png HTTP/1.1" 200 5082
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/api/patches HTTP/1.1" 200 352
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/api/languages HTTP/1.1" 200 136
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/translations/en.json HTTP/1.1" 200 34649
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/translations/fr.json HTTP/1.1" 200 28579
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "GET /guacamole/images/progress.png HTTP/1.1" 200 473
  10.0.2.2 - - [11/Oct/2018:05:12:28 +0000] "POST /guacamole/api/tokens HTTP/1.1" 500 185
  10.0.2.2 - - [11/Oct/2018:05:12:33 +0000] "GET /favicon.ico HTTP/1.1" 404 -
  ```

  Seems to be an issue with favicon:

   -  [html - Why am I seeing a 404 (Not Found) error failed to load favicon.ico when not using this? - Stack Overflow](https://stackoverflow.com/questions/39149846/why-am-i-seeing-a-404-not-found-error-failed-to-load-favicon-ico-when-not-usin?rq=1)

  Creating a dummy favicon file under `/var/tomcat/webapp/ROOT/favicon.icon` removes the favicon log entry but
  still get a blank page.

  The probleme would thus be the `POST /guacamole/api/tokens HTTP/1.1" 500 ` entry.

   -  https://sourceforge.net/p/guacamole/discussion/1110834/thread/361c108e/#da8a

      Possibly because of missing `/etc/guacamole/user-mapping.xml` file.


  ```bash
  $ cat /var/tomcat/logs/catalina.out | more
  # ...
  Authentication attempt denied because the authentication system could not be loaded
  ```

  ```bash
  $ cat /var/tomcat/logs/catalina.out
  07:03:47.399 [http-nio-8080-exec-1] ERROR o.a.g.rest.RESTExceptionWrapper - Unexpected internal error:
  ### Error querying database.  Cause: org.postgresql.util.PSQLException: Connection refused. Check that the hostname and port are correct
  ```

  Simply indicates that posgress is not started or could be accessed. The service should automatically requires postgress
  when using this backend.

  ```bash
  $ cat /var/tomcat/logs/catalina.out
  Cause: org.postgresql.util.PSQLException: FATAL: password authentication failed for user "guacamole_user"
  ```

  ```bash
  07:22:21.524 [localhost-startStop-1] ERROR o.a.g.extension.ProviderFactory - aut
  hentication provider extension failed to start: Property postgresql-password is
  required.
  ```

  ```
  07:39:12.466 [localhost-startStop-1] ERROR o.a.g.extension.ProviderFactory - aut
hentication provider extension failed to start: Property postgresql-database is
required.
  ```
*/