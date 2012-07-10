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
    cd vpn

* Download your keys and extract them into the checkout:

    scp USER@gold1-ext.rs.github.com:USER.github.com.tgz .
    tar xzvf USER.github.com.tgz
    make viscosity

* Now you should be able to connect to the VPNs from the menu bar. Boom.

* Test that the connections are working using these links

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
    make clean
    make viscosity

## Uninstall

    make clean