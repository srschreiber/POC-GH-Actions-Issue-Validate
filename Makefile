profiles = $(shell git ls-files | grep '^.*\.visc\/' | xargs -n1 dirname)
connections = $(profiles:.visc=)

ifdef BOXEN_HOME
	preflight = boxen-preflight
else
	preflight = cask-preflight
endif

.PHONY: viscosity up-to-date $(preflight) import $(connections)

install: viscosity

viscosity:
	@$(MAKE) -j1 safe-viscosity

safe-viscosity: up-to-date $(preflight) import clean

up-to-date:
	@echo "Verifying the local repo is up to date..."
	@./script/up-to-date

boxen-preflight:
	@echo "Verifying that Viscosity is installed, running Boxen otherwise..."
	@test -d /Applications/Viscosity.app || boxen vpn
	@echo "Verifying that Viscosity is functional, reinstalling otherwise..."
	@open /Applications/Viscosity.app || ( \
		rm -rf /Applications/Viscosity.app && \
		sudo rm -f /var/db/.puppet_appdmg_installed_Viscosity && \
		boxen vpn; \
		exit 0; \
	)
	@open /Applications/Viscosity.app || ( \
		echo "Viscosity still isn't functional after re-installing. Please file an issue:" \
		echo "  https://github.com/github/vpn/issues/new" && \
		exit 1; \
	)

cask-preflight:
	@echo "Verifying that Viscosity is installed, running Homebrew otherwise..."
	@brew uninstall --force brew-cask
	@brew bundle check >/dev/null || brew bundle
	@echo "Verifying that Viscosity is functional, reinstalling otherwise..."
	@open "$(shell brew cask list viscosity | tail -n1 | cut -d' ' -f1)/Viscosity.app/" || ( \
		brew cask uninstall --force viscosity && \
		brew bundle; \
		exit 0; \
	)
	@open "$(shell brew cask list viscosity | tail -n1 | cut -d' ' -f1)/Viscosity.app/" || ( \
		echo "Viscosity still isn't functional after re-installing. Please file an issue:" \
		echo "  https://github.com/github/vpn/issues/new" && \
		exit 1; \
	)

import: $(connections)

$(connections): pkcs.p12
	@echo "Importing connections...\n"
	@cp -f pkcs.p12 $@.visc/pkcs.p12
	@if grep -q -m1 -e 'name $@$$' ~/Library/Application\ Support/Viscosity/OpenVPN/*/config.conf 2>/dev/null ; then \
		p=$$(dirname "$$(grep -l -m1 -e 'name $@$$' ~/Library/Application\ Support/Viscosity/OpenVPN/*/config.conf)") ; \
		echo "Updating connection profile for $@..." ; \
		osascript -e 'tell application "Viscosity" to disconnect "$@"' && sleep 3 ; \
		cp -f $@.visc/config.conf "$$p"/config.conf ; \
		cp -f $@.visc/pkcs.p12 "$$p"/pkcs.p12 ; \
	else \
		echo "Importing new connection profile for $@..." ; \
		open $@.visc ; \
	fi
	@osascript -e 'tell application "Viscosity" to connect "$@"'

clean:
	@echo "Removing downloaded credentials..."
	@rm -f pkcs.p12 *.visc/pkcs.p12

uninstall: clean
	@echo "Disconnecting sessions, removing connections, and stopping Viscosity..."
	@osascript -e 'tell application "Viscosity" to disconnectall' && sleep 3
	@rm -rf ~/Library/Application\ Support/Viscosity/OpenVPN/*
	@killall Viscosity

pkcs.p12:
	@echo "--------------------------------------------------------------------------------"
	@echo "Fetching VPN credentials from remote.github.com. If this fails, please verify"
	@echo "you have an account and a valid SSH configuration by running:"
	@echo "  ssh remote.github.com whoami"
	@echo "--------------------------------------------------------------------------------\n"
	@scp remote.github.com:vpn-credentials.p12 pkcs.p12 || ( \
		echo "Unable to download VPN credentials. Have you run '/vpn me' in Chat?" && \
		exit 1; \
	)
	@echo ""
