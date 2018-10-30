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

preflight-uninstall:
	@echo "Verifying that Viscosity is installed, running Homebrew otherwise..."
	@brew uninstall --force brew-cask
	@brew bundle check >/dev/null || brew bundle
	@echo "Verifying that Viscosity is functional, reinstalling otherwise..."
	@open "/Applications/Viscosity.app/" || ( \
		brew cask uninstall --force viscosity && \
		brew update && \
		brew bundle; \
		exit 0; \
	)

preflight: preflight-uninstall
	@open "/Applications/Viscosity.app/" || ( \
		echo "Viscosity still isn't functional after re-installing. Please file an issue:" \
		echo "  https://github.com/github/vpn/issues/new" && \
		exit 1; \
	)

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
	/usr/bin/open /Applications/Viscosity.app/
