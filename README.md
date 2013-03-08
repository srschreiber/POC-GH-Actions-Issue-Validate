# GitHub VPN

Access all of the things. Securely.

This README assumes the following:

* You're on a Mac (if you're on Windows see the section towards the bottom of this file)
* You've setup your machine with github/setup-puppet / Boxen.
* Your GitHub repos are under `~/github` as a result of using Boxen.
* You've setup [SSH access to production](https://cerebro.githubapp.com/articles/production-shell-access) by generating a GitHub specific key and sending it to the ops@github.com email list.
* You've received an email back from a fine Opstocat with a path that looks like `jnewland@gold1-ext.rs.github.com:jnewland.github.com.tgz`

## Setup

* Clone this repo

```
cd ~/github
git clone git@github.com:github/vpn
cd vpn
```

* Download your keys and extract them into the checkout:

```
scp USER@gold1-ext.rs.github.com:USER.github.com.tgz .
tar xzvf USER.github.com.tgz
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

Good for you! The Viscosity client that Mac users use is just a GUI for OpenVPN which works great on Windows. Finding the download is a bit tricky though. Get to the [download page](http://openvpn.net/index.php/open-source/downloads.html) under the community section of OpenVPN.net, download the latest Windows installer (most likely you'll want the 64bit version). The installer will prompt you to install some fake network card drivers. You won't need anything else since the Windows version of OpenVPN includes a GUI.

Once you're done installing go ahead and download the production, staging or office (or all of them) Viscosity configuration files in this repository and change the file extension to .ovpn. Move the config files inside the config directory where you installed OpenVPN (usually c:\Program Files\OpenVPN\config).

Unpack the tar.gz file you got from the ops team ([7-Zip](http://www.7-zip.org/) is yor friend). And place them in the same directory. Now all you have to do is either rename the three files to ca.crt, key.key and cert.crt or (if you like me use OpenVPN for more than GitHub) open the config file(s) and change the ca, key and cert config options to point to the proper locations.

Start OpenVPN GUI **in administrator mode** or it won't have enough permissions to use the fake network drivers. Right click on the OpenVPN icon in the tray and you should see either just a connect menu entry (if you only installed one config) or submenus for each config. Hit connect and you're done.

### Out of TAP devices?
OpenVPN will only add one TAP device initially. You only need one TAP each _concurrent_ VPN connection so if you're not planning on being connected to more than one of prod, staging and office at a time you're good. If you need more OpenVPN adds a start menu entry for doing just that called "Add a new TAP virtual ethernet adapter".