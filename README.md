# GitHub VPN

## Access all of the things. Securely.

#### Having trouble accessing the VPN? Remove your current Viscosity and config and use the instructions below. It's super easy and it is likely get your config fixed on all of the things, instantly.

This README assumes the following:

* You're on a Mac ([running Windows?](#running-windows))
* You've setup your machine with github/setup-puppet / Boxen.
* Your GitHub repos are under `~/github` as a result of using Boxen.
* You've opened an issue on [github/ops](https://github.com/github/ops), cc'ing @github/security-ops detailing what you need to access, and why. Someone will assist with getting you keys and the right level of access.
* You've received an email back from a fine Opstocat with a path that looks like `jnewland@gold1-ext.rs.github.com:jnewland.github.com.tgz`, or some other information to get your keys.

## Setup

* Run Boxen

```
boxen vpn
cd ~/github/vpn
```

* Download your keys and extract them into the checkout:

```
ssh -A -t $USER@remote.github.net "ssh gold1 base64 $USER.github.com.tgz" | base64 -D > $USER.tgz
tar xzvf $USER.github.com.tgz
make viscosity
```

* If you are upgrading from an older install, just copy the `~/github/vpn/KEYS` directory over and run `make viscosity`.

* Look for a new icon that looks like a globe in your menu bar. This is Viscosity. Click it, and try connecting to each of the VPNs listed.

* Test that the connections are working using these links:

  * [Production](http://aux1.rs.github.com:9292/)

* Register your copy of Viscosity with this info:

```
Name:  GitHub
Email: david@github.com
Key:   VM1V-HWJAOC-46IQGJ-ZAIVX3-6ZJ4Y4-UBNVBY
```

**If this key doesn't work, email david@github.com to order more seats.**

## Updating

Viscosity makes copies of all the configurations files and keys in the
`~/Library/Application Support/Viscosity/OpenVPN` directory. If you're
updating your configuration, you'll need to either edit them via the
app OR quit Viscosity first and then open up the config files and edit them
by hand.

If you want to blow away your current config and setup things from scratch:

    killall Viscosity
    sudo killall openvpn
    make clean
    make viscosity

## Problem?

[Create a new issue](https://github.com/github/vpn/issues/new) and cc @github/ops.
Please include the logs from any failed connections. Someone from the Ops team
will help you as soon as they can!

## Uninstall

    make clean

## Running Windows?

Bless your heart! You're going to need to download and install a few things:

* [OpenVPN](http://openvpn.net/index.php/open-source/downloads.html), grabbing the latest Windows installer (64bit if you  run 64bit Windows)
* [WinSCP](http://winscp.net), for downloading your keys
* [7-Zip](http://www.7-zip.org/), for extracting

### Configure


 * Download the Viscosity configuration files you want from this repository, ie `production.visc/config.conf`
 * Change their file extension to `.ovpn` and move them inside the
   OpenVPN config directory (\Program Files\OpenVPN\Config), ie `C:\Program Files\OpenVPN\Config\production.ovpn`. PROTIP: You may need to configure windows to 'Show extensions of known files' to properly rename the file. If this was done correctly, its icon should change to resemble
 * Use WinSCP to connect to `gold1-ext.rs.github.com` and download `yourusername.github.com.tar.gz`
 * Use 7-Zip to open this file, and copy the 3 files from `yourusername.github.com.tar.gz` into the OpenVPN config directory
 * Rename the three files:
   * ca_crt to ca.crt
   * yourusername.github.com_key to key.key
   * yourusername.github.com_crt to cert.crt

### Run
 * Start OpenVPN GUI **in administrator mode** (ie right click the menu item, and select "Run as Administrator")
 * Right click on the OpenVPN icon in the tray and you should see either a connect
   menu entry (if you only installed one config) or submenus for each config.

#### Out of TAP devices?
OpenVPN will only add one TAP device initially. You need one TAP for each
_concurrent_ VPN connection. If you need more there's a start menu entry
called "Add a new TAP virtual ethernet adapter".

## For Ops.

The certificates are generated on gold1. Check /etc/ssl/Makefile for more about it.

For production access, people will need to be configured in hireadata/common.yaml . Check `github::staff::vpn` entry in [lb.pp](https://github.com/github/puppet/blob/master/modules/github/manifests/role/lb.pp) for the current set.

By default everyone receives enterprise vpn access.
