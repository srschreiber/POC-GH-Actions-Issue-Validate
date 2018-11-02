try
	set diff to do shell script "cd " & vpn_checkout_dir & "; script/up-to-date-for-applescript"
on error the error_message number the error_number
	display dialog "Error: " & the error_number & ". " & the error_message buttons {"OK"} default button 1
end try

if diff is not "" then
	display dialog "Your VPN config is out of date!

Please open a terminal:
	cd " & vpn_checkout_dir & "
	git pull
	make configure-viscosity" buttons {"I'll do that!", "Connect anyway"} default button 1
	set button_results to button returned of the result

	if button_results is "I'll do that!" then
		tell application "Viscosity" to disconnectall
	end if
end if

try
	do shell script "cd " & vpn_checkout_dir & "; script/check-certificate-validity"
on error the error_message number the error_number
	display dialog "Warning: You have VPN certificates installed that will be expiring in fewer than 7 days" buttons {"OK"} default button 1
end try
