# GitHub VPN

Use this repo to setup openvpn on your dev machine.

Assumes you have a sparse bundle setup at `/Volumes/GitHub/`.

You'll also need to setup ssh keys to be able to ssh to servers over the VPN.

## Setup

* Ask [Tim](mailto:tim@github.com) to generate some VPN keys for you

* Clone this repo

        cd /Volumes/GitHub
        git clone git@github.com:github/vpn

* Move the keys into the checkout

        mv ~/Downloads/ca_cert             /Volumes/GitHub/vpn/KEYS/ca.crt
        mv ~/Downloads/tmm1.github.com_crt /Volumes/GitHub/vpn/KEYS/my.crt
        mv ~/Downloads/tmm1.github.com_key /Volumes/GitHub/vpn/KEYS/my.key
        chmod 0600 /Volumes/GitHub/vpn/KEYS/*

* Download and install [Tunnelblick](http://code.google.com/p/tunnelblick): http://tunnelblick.googlecode.com/files/Tunnelblick_3.1.6.dmg

* Import the configurations into Tunnelblick

        open *.tblk

* Connect to the VPNs from the menu bar

  ![](http://tunnelblick.googlecode.com/files/tb-menu-screenshot-202x144px-2010-05-27.png)

* Test that the connections are working using these links

  * [CI](http://ci2.rs.github.com:8080/)
  * [Production](http://aux1.rs.github.com:9292/)
  * [Staging](http://aux1.stg.github.com:9292/)

## Updating

Tunnelblick makes copies of these configuration files in
`~/Library/Application\ Support/Tunnelblick/Configurations/`, so you
must remove the old configuration and re-import new versions.

      sudo rm -rf ~/Library/Application\ Support/Tunnelblick/Configurations/ci.tblk
      open ci.tblk

Alternatively, you can edit configuration files from inside the
Tunnelblick interface, under `Details > Edit Configuration > Unprotect and Modify`

## Uninstall

Simply remove all the configurations from Tunnelblick.

      sudo rm -rf ~/Library/Application\ Support/Tunnelblick/Configurations/*.tblk
