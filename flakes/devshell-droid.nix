{ inputs, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      devshells.droid-mfoc = {
        # Install SerialPipe, Start Server, Connect
        # https://f-droid.org/packages/io.github.wh201906.serialpipe
        # https://github.com/wh201906/SerialPipe
        devshell.startup.socat.text = ''
          echo
          echo "---------------------------------------------------------"
          if [ ! -e /tmp/serial ]; then
            socat pty,link=/tmp/serial udp4:127.0.0.1:18888 &
            echo "Socat started, run 'kill $!' when finished"
          else
            echo "Socat is already running, run 'pkill socat' when finished"
          fi
          echo "---------------------------------------------------------"
          echo
        '';
        env = [
          {
            name = "LIBNFC_DEVICE";
            value = "pn532_uart:/tmp/serial";
          }
        ];
        packages = with pkgs; [
          libnfc
          mfoc-hardnested
          socat
        ];
      };
    };
}
