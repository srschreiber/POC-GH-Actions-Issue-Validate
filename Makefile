.PHONY: viscosity

viscosity: ca_crt
	@cp ca_crt production.visc/ca.crt
	@cp ca_crt office.visc/ca.crt
	@cp *.github.com_crt production.visc/cert.crt
	@cp *.github.com_crt office.visc/cert.crt
	@cp *.github.com_key production.visc/key.key
	@cp *.github.com_key office.visc/key.key
	@chmod 600 *.visc/*.{key,crt}
	@open production.visc
	@open office.visc

clean:
	@rm -rf ~/Library/Application\ Support/Viscosity/OpenVPN/*
	@rm *.visc/*.{key,crt} || true

ca_crt:
	@test -f KEYS/ca.crt && cp KEYS/ca.crt ca_crt
	@test -f KEYS/my.crt && cp KEYS/my.crt $$USER.github.com_crt
	@test -f KEYS/my.key && cp KEYS/my.key $$USER.github.com_key
