# Current Theme
theme="$HOME/.config/rofi/powermenu.rasi"

# CMDs
uptime=$(uptime -p | sed 's/up //' | cut -d',' -f1)
host=`hostname`

# Options
shutdown='󰐥 Shutdown'
reboot='󰜉 Reboot'
lock='󰌾 Lock'
suspend='󰒲 Suspend'
logout='󰍃 Logout'
yes='✔ Yes'
no='✘ No'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "$host" \
        -no-config \
		-mesg "Uptime: $uptime" \
		-theme "$theme"
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme "$theme"
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--suspend' ]]; then
			mpc -q pause
			amixer set Master mute
			systemctl suspend
		elif [[ $1 == '--logout' ]]; then
			if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
				openbox --exit
			elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
				bspc quit
			elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
				i3-msg exit
			elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
				qdbus org.kde.ksmserver /KSMServer logout 0 0 0
			fi
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		run_cmd --shutdown
        ;;
    $reboot)
		run_cmd --reboot
        ;;
    $lock)
		if [[ -x '/usr/bin/swaylock' ]]; then
    		swaylock
		elif [[ -x '/usr/bin/i3lock' ]]; then
			i3lock
		else
    		notify-send "No screen locker found!"
		fi
        ;;
    $suspend)
		run_cmd --suspend
        ;;
    $logout)
		run_cmd --logout
        ;;
esac