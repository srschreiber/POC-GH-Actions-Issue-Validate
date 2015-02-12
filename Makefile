.PHONY: viscosity preflight

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
	@echo "All clear, setting up connections..."

viscosity: preflight production office enterprise
	@open production.visc
	@open enterprise.visc
	@open office.visc

production: ca_crt
	@cp ca_crt production.visc/ca.crt
	@cp *.github.com_crt production.visc/cert.crt
	@cp *.github.com_key production.visc/key.key
	@chmod 600 *.visc/*.{key,crt}

office: ca_crt
	@cp ca_crt office.visc/ca.crt
	@cp *.github.com_crt office.visc/cert.crt
	@cp *.github.com_key office.visc/key.key
	@chmod 600 *.visc/*.{key,crt}

enterprise: ca_crt
	@cp ca_crt enterprise.visc/ca.crt
	@cp *.github.com_crt enterprise.visc/cert.crt
	@cp *.github.com_key enterprise.visc/key.key
	@chmod 600 *.visc/*.{key,crt}

clean:
	@rm -rf ~/Library/Application\ Support/Viscosity/OpenVPN/*
	@rm *.visc/*.{key,crt} || true

ca_crt:
	@ssh remote.github.com -- "tar czf - --remove-files -C /home/$$USER ca_crt $$USER.github.com_{crt,key}" | tar xzf - -C .
