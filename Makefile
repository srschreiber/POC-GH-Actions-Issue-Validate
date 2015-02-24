.PHONY: viscosity preflight

USERNAME=`git config --get github.username`

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
	@echo "All clear, shutting down viscocity and importing connections..."
	@killall Viscosity

finalize:
	@open /Applications/Viscosity.app

viscosity: preflight production enterprise finalize
	@open production.visc
	@open enterprise.visc

production: p12
	#@osascript -e 'tell application "Viscosity" to disconnect "production"'
	for c in ~/Library/Application\ Support/Viscosity/OpenVPN/* ; do \
	  test -d "$$c" && grep -q "name production$$" "$$c/config.conf" && rm -rf "$$c" || true ; \
	done
	@cp -f pkcs.p12 production.visc/pkcs.p12
	@chmod 600 *.visc/*.p12

enterprise: p12
	#@osascript -e 'tell application "Viscosity" to disconnect "enterprise"'
	for c in ~/Library/Application\ Support/Viscosity/OpenVPN/* ; do \
	  test -d "$$c" && grep -q "name enterprise$$" "$$c/config.conf" && rm -rf "$$c" || true ; \
	done
	@cp -f pkcs.p12 enterprise.visc/pkcs.p12
	@chmod 600 *.visc/*.p12

clean:
	@rm -rf ~/Library/Application\ Support/Viscosity/OpenVPN/*
	@rm *.visc/*.{key,crt,p12} || true

p12:
	@scp remote.github.com:$(USERNAME).p12 pkcs.p12
