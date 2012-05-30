# GitHub VPN

Use this repo to setup openvpn on your dev machine.

This README assumes you've setup your machine with github/setup-puppet
and that your github repos are under `~/github` as a result.

You'll also need to setup ssh keys to be able to ssh to servers over the VPN.

## Setup

* Ask the [Ops Mailing List](mailto:ops@github.com) to generate some VPN keys for you

* Clone this repo

        cd ~/github
        git clone git@github.com:github/vpn

* Move the keys into the checkout

        mv ~/Downloads/ca_cert             ~/github/vpn/KEYS/ca.crt
        mv ~/Downloads/*.github.com_crt    ~/github/vpn/KEYS/my.crt
        mv ~/Downloads/*.github.com_key    ~/github/vpn/KEYS/my.key
        chmod 0600 ~/github/vpn/KEYS/*

* Download and install [Viscosity](http://www.thesparklabs.com/viscosity/): http://www.thesparklabs.com/viscosity/

* Open Viscosity
    * Go to Viscosity's preferences
    * In the lower left corner of the Connections pane, click the + button
    * Select 'Import Connection'
    * Navigate to ~/github/vpn and import each of the vpn.conf files in the .tblk directories
    * For each one, you'll need to to update the name to something reasonable (eg. production, staging)

* Now you should be able to connect to the VPNs from the menu bar

* Test that the connections are working using these links

  * [Production](http://aux1.rs.github.com:9292/)
  * [Staging](http://aux1.stg.github.com:9292/)

## Updating

Viscosity makes copies of all the configurations files and keys in the
`~/Library/Application Support/Viscosity/OpenVPN` directory. If you're
updating your configuration, you'll need to either edit them via the
app OR quit Viscosity first and then open up the config files and edit them
by hand.

## Uninstall

Simply remove all the configurations from Viscosity.

      sudo rm -rf ~/Library/Application\ Support/Viscosity/OpenVPN/*
