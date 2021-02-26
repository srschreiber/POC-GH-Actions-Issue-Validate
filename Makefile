.PHONY: install-viscosity up-to-date preflight certificate import import-prod import-mgmt start

# We want the steps to happen in order, but still allow them to be run individually if needed
.NOTPARALLEL: linux

install: install-viscosity

viscosity:
	@echo "To install and configure viscosity for the first time, run 'make install-viscosity'.\n"
	@echo "If viscosity is installed and you want to reconfigure it, run 'make configure-viscosity'.\n"
	@echo "Please update whichever document told you to run 'make viscosity'.\n"
	@exit 1

install-viscosity:
	@$(MAKE) -j1 safe-viscosity

safe-viscosity: up-to-date preflight certificate configure-viscosity clean start

up-to-date:
	@echo "Verifying the local repo is up to date..."
	@./script/up-to-date

check:
	@./script/check

preflight:
	@./script/install-viscosity

configure-viscosity:
	@./script/configure-viscosity

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

configure-nm:
	@./script/configure-nm

linux: up-to-date certificate configure-nm

windows-import:
	@./script/windows

windows: up-to-date certificate windows-import

unsupported:
	@./script/unsupported
