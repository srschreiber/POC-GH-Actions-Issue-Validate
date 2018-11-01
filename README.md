# GitHub VPN

**The authoritative document on VPN access is in [GitHubber](https://githubber.com/article/crafts/engineering/production-vpn-access).**

## Troubleshooting

### VPN + Duo

All VPN endpoints require Duo. Our Duo implementation for the VPN is a little bit non-standard and there are a few things that you need to know:

1. Duo Push is the only method that we support for VPN therefore you must have the Duo app installed and activated.
2. Duo is only required once every 24 hours for each site you connect to as long as you are connecting from the same IP.
3. Viscosity has no mechanism to tell you that you need to answer a Duo prompt, so its best to have your mobile device handy when VPNing.
4. If you fail to answer the Duo prompt within 1 minute of connecting, the VPN server will forcibly disconnect you. For viscosity users, this will appear as an "Authentication Failed" message.

### If something goes wrong during Setup - Try These Steps

1. Clone this repo into ~/github
1. Run `.vpn me` in chat
1. scp the pkcs.p12 file by running the following command ```scp vault-bastion.githubapp.com:vpn-credentials.p12 pkcs.p12```
1. Download Viscosity from https://gear.githubapp.com/apps/
1. Install Viscosity this will create directory `~/Library/Application Support/Viscosity/OpenVPN`
1. Navigate to this directory, create folders with names 1 - 7. This is because there are 7 types of connections. Example:
    ```
    ~/Library/Application Support/Viscosity/OpenVPN/1/
    ~/Library/Application Support/Viscosity/OpenVPN/2/
    ~/Library/Application Support/Viscosity/OpenVPN/3/
    ~/Library/Application Support/Viscosity/OpenVPN/4/
    ~/Library/Application Support/Viscosity/OpenVPN/5/
    ~/Library/Application Support/Viscosity/OpenVPN/6/
    ~/Library/Application Support/Viscosity/OpenVPN/7/
    ```
1. Now there are 7 folders in the root of this repo (github/vpn) with `config.conf` files. Copy these files (order doesn't matter) into each of the folders you just created.

1. Copy that `pkcs.p12` file you scp'd in step 3 to each of the directories in `~/Library/Application Support/Viscosity/OpenVPN/`  You just replicate this same file in each of these directories.

1.  Open Viscosity (CMD + Space type Viscosity) - a Globe icon will appear in your menubar

1.  Try to connect!  It should work now!

## Updating

Viscosity makes copies of all the configurations files and keys in the
`~/Library/Application Support/Viscosity/OpenVPN` directory. If you're
updating your configuration, you'll need to either edit them via the
app OR quit Viscosity first and then open up the config files and edit them
by hand.

If you want to blow away your current config and setup things from scratch:

    `.vpn me` in Slack
    make uninstall
    make

## Problem?

[Create a new issue](https://github.com/github/vpn/issues/new) and cc
@github/security-ops.  Please include the logs from any failed connections.
Someone from the Ops team will help you as soon as they can!

## Uninstall

    make uninstall

## Running Windows?

Bless your heart! You're going to need to download and install a few things:

* [OpenVPN](http://openvpn.net/index.php/open-source/downloads.html), grabbing the latest Windows installer (64bit if you run 64bit Windows)
* [WinSCP](http://winscp.net), for downloading your keys

### Configure

 * Download the Viscosity configuration files you want from this repository, ie `github-iad-prod.visc/config.conf`
 * Change their file extension to `.ovpn` and move them inside the
   OpenVPN config directory (\Program Files\OpenVPN\Config), ie `C:\Program Files\OpenVPN\Config\github-iad-prod.ovpn`. PROTIP: You may need to configure windows to 'Show extensions of known files' to properly rename the file. If this was done correctly, its icon should change to resemble
 * Run `.vpn me` in Chat
 * Use WinSCP to connect to `vault-bastion.githubapp.com` and download `vpn-credentials.p12` into the OpenVPN config directory.

### Run
 * Start OpenVPN GUI **in administrator mode** (ie right click the menu item, and select "Run as Administrator")
 * Right click on the OpenVPN icon in the tray and you should see either a connect
   menu entry (if you only installed one config) or submenus for each config.

#### Out of TAP devices?
OpenVPN will only add one TAP device initially. You need one TAP for each
_concurrent_ VPN connection. If you need more there's a start menu entry
called "Add a new TAP virtual ethernet adapter".

## For Ops.

The certificates are generated on `shell.service.cp1-iad.github.net`. Check `/data/vpn-ca` and the [github/vpn-ca](https://github.com/github/vpn-ca) repo for more info about the CA store.
