profiles = $(wildcard *.visc)
connections = $(profiles:.visc=)

.PHONY: viscosity preflight import $(connections)

viscosity: preflight import purge

preflight:
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
	@osascript -e 'tell application "Viscosity" to disconnect "$@"' && sleep 3
	@cp -f pkcs.p12 $@.visc/pkcs.p12
	@for c in ~/Library/Application\ Support/Viscosity/OpenVPN/* ; do \
		if test -d "$$c" ; then \
			if grep -q -e "name $@$$" "$$c/config.conf" ; then \
				echo "Updating connection profile for $@..." ; \
				cp -f $@.visc/config.conf "$$c"/config.conf ; \
				cp -f $@.visc/pkcs.p12 "$$c"/pkcs.p12 ; \
			fi ; \
		else \
			echo "Importing new connection profile for $$c..." ; \
			open $@.visc ; \
		fi ; \
	done
	@osascript -e 'tell application "Viscosity" to connect "$@"'

purge: pkcs.p12
	@echo "Backing up credentials to pkcs-backup.p12..."
	@mv -f pkcs.p12 pkcs-backup.p12
	@rm -f *.visc/pkcs.p12

clean:
	@osascript -e 'tell application "Viscosity" to disconnectall'
	@rm -rf ~/Library/Application\ Support/Viscosity/OpenVPN/*
	@rm *.visc/*.{key,crt,p12} || true

pkcs.p12:
	@echo "--------------------------------------------------------------------------------------------------"
	@echo "Fetching VPN credentials from remote.github.com. If this fails, please verify you have an account "
	@echo "and a valid SSH configuration by running \`ssh remote.github.com whoami\`"
	@echo "--------------------------------------------------------------------------------------------------\n"
	@scp remote.github.com:vpn-credentials.p12 pkcs.p12
	@echo ""
