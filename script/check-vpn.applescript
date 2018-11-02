set button_results to ""
set diff to ""

try
	set diff to do shell script "cd " & vpn_checkout_dir & "; script/up-to-date-for-applescript"
on error the error_message number the error_number
	if error_number is 127 then
		display dialog "Your checkout of the VPN repo appears to have moved.
Is is no longer in " & vpn_checkout_dir & ".

Please open a terminal:
  cd $your_vpn_checkout
  make" buttons {"I'll do that!", "Connect anyway"} default button 1
		set button_results to button returned of the result
		if button_results is "I'll do that!" then
			tell application "Viscosity" to disconnectall
			return
		end if
	else
		display dialog "Error: " & the error_number & ". " & the error_message buttons {"OK"} default button 1
	end if
end try

if diff is not "" then
	display dialog "Your VPN config is out of date!

Please open a terminal:
  cd " & vpn_checkout_dir & "
  make" buttons {"I'll do that!", "Connect anyway"} default button 1
	set button_results to button returned of the result
	if button_results is "I'll do that!" then
		tell application "Viscosity" to disconnectall
		return
	end if
end if


try
	do shell script "export PASS=''; IFS=$'\\n'; for f in `find ~/Library/Application\\ Support/Viscosity/OpenVPN/ -name *.p12 -type f`; do  openssl pkcs12 -in $f -nokeys -passin env:PASS 2> /dev/null | openssl x509 -noout -checkend 0; ret=$?; if [[ $ret -ne 0 ]]; then exit $ret; fi; done"
on error the error_message number the error_number
	display dialog "Warning: You have VPN certificates that have expired.

Please open a terminal:
  cd " & vpn_checkout_dir & "
  make" buttons {"I'll do that!", "Connect anyway"} default button 1
	
	if button_results is "I'll do that!" then
		tell application "Viscosity" to disconnectall
		return
	end if
end try

try
	do shell script "export PASS=''; IFS=$'\\n'; for f in `find ~/Library/Application\\ Support/Viscosity/OpenVPN/ -name *.p12 -type f`; do  openssl pkcs12 -in $f -nokeys -passin env:PASS 2> /dev/null | openssl x509 -noout -checkend 2520; ret=$?; if [[ $ret -ne 0 ]]; then exit $ret; fi; done"
on error the error_message number the error_number
	display dialog "Warning: You have VPN certificates installed that will be expiring in fewer than 7 days.

If you wish to renew them before expiration:
	run the chat-op \".vpn-new revoke\"
	cd " & vpn_checkout_dir & "
	make" buttons {"OK"} default button 1
end try
