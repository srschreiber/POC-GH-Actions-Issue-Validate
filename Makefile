profiles = $(shell git ls-files | grep '^.*\.visc\/' | xargs -n1 dirname)
connections = $(profiles:.visc=)

.PHONY: viscosity preflight import $(connections)

install: viscosity

viscosity:
	@$(MAKE) -j1 safe-viscosity

safe-viscosity: preflight import clean

preflight:
	@echo "Verifying the local repo is up to date..."
	@./script/up-to-date
	@echo "Verifying that viscosity is installed, running boxen otherwise..."
	@test -d /Applications/Viscosity.app || boxen vpn
	@echo "Verifying that Viscosity is functional, blowing away and reinstalling otherwise..."
	@open /Applications/Viscosity.app || ( \
		rm -rf /Applications/Viscosity.app && \
		sudo rm -f /var/db/.puppet_appdmg_installed_Viscosity && \
		boxen vpn; \
		exit 0; \
	)
	@open /Applications/Viscosity.app || ( \
		echo "Viscosity still isn't functional after re-installing. Please file an issue: https://github.com/github/vpn/issues/new" && \
		exit 1; \
	)
	@echo "Importing connections...\n"

import: $(connections)

$(connections): pkcs.p12
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
	@echo "--------------------------------------------------------------------------------------------------"
	@echo "Fetching VPN credentials from remote.github.com. If this fails, please verify you have an account "
	@echo "and a valid SSH configuration by running \`ssh remote.github.com whoami\`"
	@echo "--------------------------------------------------------------------------------------------------\n"
	@scp remote.github.com:vpn-credentials.p12 pkcs.p12
	@echo ""
