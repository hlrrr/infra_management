# Ubuntu

- add service
  ```
  ex) telnet

  apt install xinetd telnetd
  /etc/xinetd.d
  touch [service_name]

  service telnet
  {
    disable = no
    socket_type = stream
    wait = no
    server = /usr/sbin/telnetd
    user = root
  }
  ```

# RedHat

- "sysctl --system"  VS  "sysctl -p"
  -  "--system" option reload systemwide kernel parameter under dirs:
      ```
      /etc/sysctl.conf
      /etc/sysctl.d/*.conf
      /usr/lib/sysctl.d/*.conf
      /run/sysctl.d/*.conf
      ```

  - " --p" option reload single conf file:
    ```
    /etc/sysctl.conf
    (default, can be changed)
    ```
