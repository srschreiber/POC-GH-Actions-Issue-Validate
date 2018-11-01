try
	set diff to do shell script "cd " & vpn_checkout_dir & "; sleep 10;  git fetch; git diff origin/master"
on error the error_message number the error_number
	display dialog "Error: " & the error_number & ". " & the error_message buttons {"OK"} default button 1
end try

if diff is not "" then
	display dialog "Your VPN config is out of date!
	
Please open a terminal:
	cd " & vpn_checkout_dir & "
	git pull
	make && make install" buttons {"I'll do that!", "Connect anyway"} default button 1
	set button_results to button returned of the result
end if


if button_results is "I'll do that!" then
	tell application "Viscosity" to disconnectall
else
	
end if

-- do shell script "export PASS=''; IFS=$'\\n'; for f in `find ~/Library/Application\\ Support/Viscosity/OpenVPN/ -name *.p12 -type f`; do echo $f; openssl pkcs12 -in $f -nokeys -passin env:PASS 2> /dev/null | openssl x509 -noout -checkend 25200; ret=$?; echo $ret; done"

try
	do shell script "export PASS=''; IFS=$'\\n'; for f in `find ~/Library/Application\\ Support/Viscosity/OpenVPN/ -name *.p12 -type f`; do echo $f; openssl pkcs12 -in $f -nokeys -passin env:PASS 2> /dev/null | openssl x509 -noout -checkend 25200; ret=$?; if [[ $ret -ne 0 ]]; then exit $ret; fi; done"
on error the error_message number the error_number
	display dialog "Warning: You have VPN certificates installed that will be expiring in fewer than 7 days" buttons {"OK"} default button 1
end try
