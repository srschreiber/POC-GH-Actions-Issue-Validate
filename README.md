# GitHub VPN

Access all of the things. Securely.

This README assumes the following:

* You've setup your machine with github/setup-puppet
* Your GitHub repos are under `~/github` as a result of using The Setup
* You've asked the [Ops Mailing List](mailto:ops@github.com) to setup SSH and generate VPN keys for you
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

* Look for a new icon that looks like a globe in your menu bar. This is Viscosity. Click it, and try connecting to each of the VPNs listed.

* Test that the connections are working using these links:

  * [Production](http://aux1.rs.github.com:9292/)
  * [Staging](http://aux1.stg.github.com:9292/)

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