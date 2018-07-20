prod_profiles = $(shell git ls-files | grep '^.*-prod.*\.visc\/' | xargs -n1 dirname)
mgmt_profiles = $(shell git ls-files | grep '^.*-mgmt\.visc\/' | xargs -n1 dirname)
prod_connections = $(prod_profiles:.visc=)
mgmt_connections = $(mgmt_profiles:.visc=)
connections = $(prod_connections) $(mgmt_connections)

.PHONY: viscosity up-to-date preflight import import-prod import-mgmt $(connections)

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

import: import-prod

import-prod: $(prod_connections)

import-mgmt: $(mgmt_connections)

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

clean:
	@echo "Removing downloaded credentials..."
	@rm -f pkcs.p12 *.visc/pkcs.p12
	@if grep -q -m1 -e 'name github-production$$' ~/Library/Application\ Support/Viscosity/OpenVPN/*/config.conf 2>/dev/null ; then \
		p=$$(dirname "$$(grep -l -m1 -e 'name github-production$$' ~/Library/Application\ Support/Viscosity/OpenVPN/*/config.conf)") ; \
		echo "Cleaning up github-production VPN..." ; \
		mv "$$p" "$$HOME/viscosity-github-production.off" ; \
		killall Viscosity ; \
		echo "Please restart viscosity to finish the cleanup" ; \
	fi

uninstall: clean
	@echo "Disconnecting sessions, removing connections, and stopping Viscosity..."
	@osascript -e 'tell application "Viscosity" to disconnectall' && sleep 3
	@rm -rf ~/Library/Application\ Support/Viscosity/OpenVPN/*
	@killall Viscosity

pkcs.p12:
	@echo "--------------------------------------------------------------------------------"
	@echo "Fetching VPN credentials from shell.service.cp1-iad.github.net via bastion.githubapp.com. If this fails, please verify"
	@echo "you have an account and a valid SSH configuration by running:"
	@echo "  ssh -o \"ConnectTimeout 120\" -o \"ProxyJump bastion.githubapp.com\" shell.service.cp1-iad.github.net whoami"
	@echo "--------------------------------------------------------------------------------\n"
	@ssh -o "ConnectTimeout 120" -o "ProxyJump bastion.githubapp.com" shell.service.cp1-iad.github.net "cat ~/vpn-credentials.p12" > pkcs.p12
	@test -s "pkcs.p12" || ( \
		echo "Unable to download VPN credentials. Have you run '.vpn me' in Chat?" && \
		exit 1; \
	)
	@echo | openssl pkcs12 -in pkcs.p12 -passin fd:0 -clcerts -nokeys 2>/dev/null | openssl x509 -noout -checkend 0 || ( \
		echo "\n###############\n# ! WARNING ! # your certificate has expired. Please run '.vpn renew' in chat.\n###############\n" && \
		exit 1; \
	)
