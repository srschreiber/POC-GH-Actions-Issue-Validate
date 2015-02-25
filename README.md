# GitHub VPN

## Access all of the things. Securely.

#### Having trouble accessing the VPN?

Try this:

    Run `/vpn me` in Chat
    cd ~/github/vpn
    git pull origin master
    make viscosity

## Setup

This README assumes the following:

* You're on a Mac ([running Windows?](#running-windows))
* You've setup your machine with Boxen.
* Your GitHub repos are under `~/github` as a result of using Boxen.
* You've opened an issue on [github/ops](https://github.com/github/ops), cc'ing @github/security-ops detailing what you need to access, and why, and you've been added to the VPN users.


* Run Boxen

```
boxen vpn
cd ~/github/vpn
```

* Setup the VPN connections

```
make
```

* Look for a new icon that looks like a globe in your menu bar. This is Viscosity. Click it, and verify each of the VPNs listed have connected.

* Test that the connections are working using these links:

  * [Production](http://mirror.iad.github.net/)

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

    `/vpn me` in Chat
    make uninstall
    make

## Problem?

[Create a new issue](https://github.com/github/vpn/issues/new) and cc @github/ops.
Please include the logs from any failed connections. Someone from the Ops team
will help you as soon as they can!

## Uninstall

    make uninstall

## Running Windows?

Bless your heart! You're going to need to download and install a few things:

* [OpenVPN](http://openvpn.net/index.php/open-source/downloads.html), grabbing the latest Windows installer (64bit if you run 64bit Windows)
* [WinSCP](http://winscp.net), for downloading your keys

### Configure

 * Download the Viscosity configuration files you want from this repository, ie `github-production.visc/config.conf`
 * Change their file extension to `.ovpn` and move them inside the
   OpenVPN config directory (\Program Files\OpenVPN\Config), ie `C:\Program Files\OpenVPN\Config\github-production.ovpn`. PROTIP: You may need to configure windows to 'Show extensions of known files' to properly rename the file. If this was done correctly, its icon should change to resemble
 * Run `/vpn me` in Chat
 * Use WinSCP to connect to `remote.github.com` and download `vpn-credentials.p12` into the OpenVPN config directory
 * Download the CA certificate from [github/puppet](https://github.com/github/puppet/blob/7475edc21fec64ff82f33c2e8f30d1873d676a23/modules/github/files/etc/ssl/ca_crt) into the same folder
 * Rename the PKCS#12 container from `vpn-credentials.p12` to `pkcs.p12`

### Run
 * Start OpenVPN GUI **in administrator mode** (ie right click the menu item, and select "Run as Administrator")
 * Right click on the OpenVPN icon in the tray and you should see either a connect
   menu entry (if you only installed one config) or submenus for each config.

#### Out of TAP devices?
OpenVPN will only add one TAP device initially. You need one TAP for each
_concurrent_ VPN connection. If you need more there's a start menu entry
called "Add a new TAP virtual ethernet adapter".

## For Ops.

The certificates are generated on ops-vpn1. Check `/data/vpn-ca` and the [github/vpn-ca](https://github.com/github/vpn-ca) repo for more info about the CA store.

For production access, people will need to be configured in `hieradata/common.yaml` . Check `github::staff::vpn` entry in [lb.pp](https://github.com/github/puppet/blob/master/modules/github/manifests/role/lb.pp) for the current set.

By default everyone receives enterprise vpn access.
