# GitHub VPN

**The authoritative document on VPN access is on [TheHub](https://thehub.github.com/engineering/security/production-vpn-access/).**

## Troubleshooting

### VPN + Duo

All VPN endpoints require Duo. Our Duo implementation for the VPN is a little bit non-standard and there are a few things that you need to know:

1. Duo Push is the only method that we support for VPN therefore you must have the Duo app installed and activated.
2. Duo is only required once every 24 hours for each site you connect to as long as you are connecting from the same IP.
3. Viscosity has no mechanism to tell you that you need to answer a Duo prompt, so its best to have your mobile device handy when VPNing.
4. If you fail to answer the Duo prompt within 1 minute of connecting, the VPN server will forcibly disconnect you. For viscosity users, this will appear as an "Authentication Failed" message.

### If something goes wrong during Setup - Try These Steps

1. Uninstall Viscosity if it was previously installed
1. Clone this repo into ~/github
1. Run `make certificate` -- when Viscosity isn't installed this will drop `pkcs.p12` into this directory
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

1. Copy that `pkcs.p12` file from the `make certificate` step into each of the directories in `~/Library/Application Support/Viscosity/OpenVPN/`  You just replicate this same file in each of these directories. Example command:
    ```
    for i in 1 2 3 4 5 6 7; do cp pkcs.p12 ~/Library/Application\ Support/Viscosity/OpenVPN/$i/ ; done
    ````

1.  Open Viscosity (CMD + Space type Viscosity) - a Globe icon will appear in your menubar

1.  Try to connect!  It should work now!

## Updating

Viscosity makes copies of all the configurations files and keys in the
`~/Library/Application Support/Viscosity/OpenVPN` directory. If you're
updating your configuration, you'll need to either edit them via the
app OR quit Viscosity first and then open up the config files and edit them
by hand.

If you want to blow away your current config and setup things from scratch:

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
* [PuTTY](https://www.putty.org), if you don't have an SSH client already
* [WinSCP](http://winscp.net), for downloading your keys, if you don't have a SCP client already

### Configure

#### macOS

 * Download the Viscosity configuration files you want from this repository, ie `github-iad-prod.visc/config.conf`
 * Change their file extension to `.ovpn` and move them inside the
   OpenVPN config directory (\Program Files\OpenVPN\Config), ie `C:\Program Files\OpenVPN\Config\github-iad-prod.ovpn`. PROTIP: You may need to configure windows to 'Show extensions of known files' to properly rename the file. If this was done correctly, its icon should change to resemble
 * SSH to `vault-bastion.githubapp.com` (see https://githubber.com/article/crafts/engineering/production-shell-access for all the specifics around keys and authorization). You'll need to accept a Duo push to log in. Once you're logged in run these commands in the order shown and make sure that the output looks similar:

      ```
      bob@vault-bastion-a642f4f.vpc-us-east-1(prd) ~ $ . vault-login
      Hello, bob.
      github.com password:
      Please check your device for a Duo push to complete your login.
      Login succeeded. VAULT_TOKEN has been set in your environment.
      Successfully authenticated. Your vault token has been set in the environment.

      bob@vault-bastion-a642f4f.vpc-us-east-1(prd) ~ $ /data/vpn-credential-issuer/bin/vpn-credential-issuer.sh | tail -1 | base64 -d > ~/vpn-credentials.p12

      bob@vault-bastion-a642f4f.vpc-us-east-1(prd) ~ $ ls -l ~/vpn-credentials.p12
      -rw-r--r-- 1 bob users 7922 Nov  1 08:35 /home/bob/vpn-credentials.p12
      ```

 * Use WinSCP to connect to `vault-bastion.githubapp.com` and download `vpn-credentials.p12` into the OpenVPN config directory.
 * Delete `vpn-credentials.p12` off the server, because :lock:.

#### Linux

You'll need Network Manager running. It should be working out of the box with Ubuntu and Fedora.

To download certificates and add VPN profiles to Network Manager run:

`make linux`

### Run
 * Start OpenVPN GUI **in administrator mode** (ie right click the menu item, and select "Run as Administrator")
 * Right click on the OpenVPN icon in the tray and you should see either a connect
   menu entry (if you only installed one config) or submenus for each config.

#### Out of TAP devices?
OpenVPN will only add one TAP device initially. You need one TAP for each
_concurrent_ VPN connection. If you need more there's a start menu entry
called "Add a new TAP virtual ethernet adapter".
