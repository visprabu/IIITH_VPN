# IIITH VPN

Bash script to start/stop OpenVPN service for IIITH users.

Execute the script as a root user

``` console

$ sudo bash IIITH_vpn.sh

```

**Works only for iiit.ac.in accounts**

##### Notes:

+ Files generated by the script:
    + ubuntu.ovpn (config file from vpn.iiit.ac.in)
    + out_wget.txt (contains output of wget)
    + .auth.txt (contains username and password for automatic login in OpenVPN)
    + openvpn.ovpn (changed copy of ubuntu.ovpn - used for OpenVPN)

+ User Name & Password only required for first login and gets stored in .auth.txt for further OpenVPN use.
