# reset root passwd
- press `e` to stop boot process
- mod `ro -> rw`, add `init=/bin/bash`
- `passwd` reset passwd
- `touch /.autorelabel`, `exec /sbin/init` relabel SELiunx and initialize the system

# nmcli
- `nmcli device show` check NIC name
- `nmcli conn mod [NIC name] ipv4.addresses [ip addr/prefix]` mod values
- `ipv4.addresses .gateway .dns` , `ipv4.method manual` nmcli cmds
- `nmcli conn down/up  [NCI name]` restart NIC

