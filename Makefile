.PHONY: viscosity up-to-date preflight certificate import import-prod import-mgmt start

install: viscosity

viscosity:
	@$(MAKE) -j1 safe-viscosity

safe-viscosity: up-to-date preflight certificate clean start

up-to-date:
	@echo "Verifying the local repo is up to date..."
	@./script/up-to-date

check:
	@./script/check

preflight:
	@./script/install-viscosity

import-prod:
	@echo "VPN certificate issuance now imports all connections to which you are entitled.\n"
	@echo "Just run 'make' instead. Please update whichever document told you to run this command.\n"
	@exit 1

import-mgmt:
	@echo "VPN certificate issuance now imports all connections to which you are entitled.\n"
	@echo "Just run 'make' instead. Please update whichever document told you to run this command.\n"
	@exit 1

import: certificate

certificate:
	@./script/get-certificate

clean:
	@echo "Removing downloaded credentials..."
	@rm -f pkcs.p12 *.visc/pkcs.p12

uninstall: clean
	@echo "Disconnecting sessions, removing connections, and stopping Viscosity..."
	@osascript -e 'tell application "Viscosity" to disconnectall' && sleep 3
	@rm -rf ~/Library/Application\ Support/Viscosity/OpenVPN/*
	@killall Viscosity

pkcs.p12:
	@echo "VPN certificate issuance now imports all connections to which you are entitled.\n"
	@echo "Just run 'make' instead. Please update whichever document told you to run this command.\n"
	@exit 1

start:
	@echo "Starting Viscosity..."
	@/usr/bin/open /Applications/Viscosity.app/
