# GitHub VPN

## Setup

* Ask [Tim](tim@github.com) to generate some VPN keys for you
* Clone this repo

      cd /Volumes/GitHub
      git clone git@github.com:github/vpn

* Move the keys into the checkout

      mv ~/Downloads/ca_cert             /Volumes/GitHub/vpn/KEYS/ca.crt
      mv ~/Downloads/tmm1.github.com_crt /Volumes/GitHub/vpn/KEYS/my.crt
      mv ~/Downloads/tmm1.github.com_key /Volumes/GitHub/vpn/KEYS/my.key

* Download and install [Tunnelblick](http://code.google.com/p/tunnelblick): http://tunnelblick.googlecode.com/files/Tunnelblick_3.1.6.dmg
* Import the configurations into Tunnelblick

      open production.tblk
      open staging.tblk
      open ci.tblk

## Uninstall

    sudo rm -rf ~/Library/Application\ Support/Tunnelblick/Configurations/*.tblk
