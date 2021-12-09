global tokenValue
on get_token(t)
  tell application "Google Chrome"
    tell t to execute javascript "document.getElementById('token')?.value || ''"
  end tell
end get_token

on is_on_auth_form(t)
  tell application "Google Chrome"
    tell t to execute javascript "document.forms[0].lastElementChild.innerText == 'AUTHORIZE ME '"
  end tell
end is_on_auth_form

on submit_form(t)
  delay 0.5
  tell application "Google Chrome"
    tell t to execute javascript "document.forms[0].submit()"
  end tell
end submit_form

on run argv
  tell application "Google Chrome"
    tell first window
      set tokenWindow to make new tab with properties {URL:"https://fido-challenger.githubapp.com/auth/vpn-devvpn"}
	  repeat while my is_on_auth_form(tokenWindow) is false
        delay 0.5
      end repeat

      my submit_form(tokenWindow)
      repeat while my get_token(tokenWindow) is ""
        delay 0.5
      end repeat
      set tokenValue to my get_token(tokenWindow)
      tell tokenWindow to close
    end tell
  end tell

  tell application "Viscosity" to connect "github-iad-devvpn"

  tell application "System Events"
    tell process "Viscosity"
      delay 2
      repeat until exists text field 1 of window 1
      end repeat
      set value of text field 1 of window 1 to tokenValue
      click button "OK" of window 1
    end tell
  end tell
end run
