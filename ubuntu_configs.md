# add service

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
