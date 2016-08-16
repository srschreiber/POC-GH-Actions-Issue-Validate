profiles = $(shell git ls-files | grep '^.*\.visc\/' | xargs -n1 dirname)
connections = $(profiles:.visc=)

.PHONY: viscosity up-to-date preflight import $(connections)

install: viscosity

viscosity:
	@$(MAKE) -j1 safe-viscosity

safe-viscosity: up-to-date preflight import clean

up-to-date:
	@echo "Verifying the local repo is up to date..."
	@./script/up-to-date

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
	@echo "Fetching VPN credentials from remote.github.net. If this fails, please verify"
	@echo "you have an account and a valid SSH configuration by running:"
	@echo "  ssh remote.github.net whoami"
	@echo "--------------------------------------------------------------------------------\n"
	@scp remote.github.net:vpn-credentials.p12 pkcs.p12 || ( \
		echo "Unable to download VPN credentials. Have you run '.vpn me' in Chat?" && \
		exit 1; \
	)
	@[ $$(date -j -f "%b %d %H:%M:%S %Y %Z" "$$( echo | openssl pkcs12 -in pkcs.p12 -passin fd:0 -clcerts -nokeys 2>/dev/null | openssl x509 -noout -text | grep 'Not After' | sed -e 's/.[^:]*:[[:space:]]*//')" +'%s') -lt $$(date +'%s') ] && echo "\n###############\n# ! WARNING ! # your certificate has expired. Please run '.vpn renew' in chat.\n###############\n" || true
