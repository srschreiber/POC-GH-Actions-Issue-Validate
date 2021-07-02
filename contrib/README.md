# Contrib scripts

The directory contains some contributed scripts to help automate connecting to the vpn. These scripts take care of the entire process of:

* Navigating to the correct fido-challenger website
* Getting the token from the website
* Connecting to the VPN
* Filling out the challenge prompt with the token

## Assumptions

The scripts assume OSX, Google Chrome, and only connect to `github-iad-prod` or `github-iad-devvpn`. 

To let the scripts run on Google Chrome, you need to enable javascript from Apple events. To do that go to 

```
View -> Developer -> Allow JavaScript from Apple Events
```

## How to run

Provided in this contrib dir are two applescript files that are able to executed via `osascript`

```
# Connect to prod vpn
osascript connect-github-iad-prod.applescript

# Connect to dev vpn
osascript connect-github-iad-devvpn.applescript
```

Also provided are two Alfred workflows that execute the same applescript scripts.

* `github-iad-devvpn_vpn_connect.alfredworkflow` - connects to the devvpn via the `devvpn` keyword
* `github-iad-prod_vpn_connect.alfredworkflow` - connects to the vpn via the `vpn` keyword
