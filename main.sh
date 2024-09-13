#!/bin/bash
# TacacsGUI Main Script
# Original Author: Aleksey Mochalin
# Updated by ichantio

####  VARIABLES  ####
####
####  FUNCTIONS ####
ROOT_PATH="/opt/tacacsgui";
source "$ROOT_PATH/scripts/functions/map.sh";
source "$FUN_GENERAL";
####  FUNCTIONS ####  END

if [ $# -eq 0 ]
then
	echo "Error!";
	exit 0;
fi

case $1 in
	uuid_hash)
		echo $(sudo dmidecode -s system-uuid)_$(sudo dmidecode -s system-serial-number) | sha256sum | head -c 64
	;;
	ha)
		$CMDRUN $HA_SCRIPT_PATH $(printf "%s\n" "${@:2}");
	;;
	run)
		case $2 in
			cmd)
				$CMDRUN $(printf "%s\n" "${@:3}");
			;;
		esac
	;;
	check)
		case $2 in
		mavis)
			/usr/local/bin/mavistest $ROOT_PATH/tac_plus.cfg_test tac_plus TACPLUS $3 $4
		;;

		ldapsearch)
			# ldapsearch -x -LLL -h WIN-I8GVEDVHNBK.WIN2008.G33 -D "CN=Alexey AM,CN=Users,DC=win2008,DC=g33" -w cisco123 -b 'CN=Users,DC=win2008,DC=g33' -s sub '(&(objectclass=user)(sAMAccountName=user2))'
		;;

		smpp-client)
			# php $ROOT_PATH/mavis-modules/sms/smpptest.php <type> <ipddr> <port> <debug> <login> <pass> <srcname> <number> <username>
			php $ROOT_PATH/mavis/sms/smpptest.php "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}"
		;;

		*)
			echo 'Unexpected argument for check. Exit.'
			exit 0
		;;
		esac
	;;
	delete)
		#find $ROOT_PATH/$3 -mmin +15 -exec rm -f {} \;
		case $2 in
			temp)
				find $ROOT_PATH/temp/ ! -name '.gitkeep' -mmin +15 -type f -exec rm -f {} \;
				echo -n 0;
			;;
			temp-file)
				case $3 in
					notification-settings)
						rm /opt/tgui_data/tmp_notification_settings.yaml
					;;
				esac
			;;
		esac
	;;
	network)
		if [[ ! -z $2 ]] && [[ $2 -eq 'save' ]]; then
			/opt/tacacsgui/interfaces.py -s ${@:3}
		fi
	;;
	tac_plus)
		if [[ ! -z $2 ]] || [[ $2 -eq 'start' ]] || [[ $2 -eq 'stop' ]] || [[ $2 -eq 'restart' ]] || [[ $2 -eq 'status' ]]; then
			if [[ ! -f /etc/init/tac_plus.conf ]]; then
touch /etc/init/tac_plus.conf
echo '# tac_plus daemon
description "tac_plus daemon"
author "Marc Huber"
start on runlevel [2345]
stop on runlevel [!2345]
respawn
# Specify working directory
chdir /opt/tacacsgui
exec tac_plus.sh' > /etc/init/tac_plus.conf;
cp $ROOT_PATH/tac_plus.sh /etc/init.d/tac_plus
	sudo systemctl enable tac_plus
			fi

			if [[ ! -z $3 ]] && [[ $3 -eq 'brief' ]]; then
				service tac_plus $2 | grep 'Active:';
			else
				service tac_plus $2
			fi
		fi
	;;
	ntp)
		case $2 in
		get-time)
			date "+%F %T"
		;;
		get-timezone)
			timedatectl | grep 'Time zone:' | awk '{ print $3 }'
		;;
		timezone)
			timedatectl set-timezone $3
			timedatectl set-ntp false
		;;
		get-config)
			# Check if it's ntpsec or ntp
			if systemctl is-active --quiet ntpsec.service; then
				NTP_SERVICE="ntpsec.service"
				NTP_CONF="/etc/ntpsec/ntp.conf"
			elif systemctl is-active --quiet ntp.service; then
				NTP_SERVICE="ntp.service"
				NTP_CONF="/etc/ntp.conf"
			else
				echo -n 0;
				exit 0;
			fi
			# Check if temp ntp.conf file exists
			if [[ ! -f "$ROOT_PATH/temp/ntp.conf" ]]; then
				echo -n 0;
				exit 0;
			fi
			if [[ ! -f $ROOT_PATH/temp/ntp.conf ]]; then
				echo -n 0;
				exit 0;
			fi
			if [[ $(grep -c "TACACS" "$NTP_CONF") != "1" ]]; then
				mv "$NTP_CONF" "${NTP_CONF}_old"
			fi
			mv $ROOT_PATH/temp/ntp.conf "$NTP_CONF"
			sleep 1;
			timedatectl set-ntp false
			sudo systemctl restart "$NTP_SERVICE"
			echo -n 1
			exit 0
		;;

		*)
			echo 'Unexpected argument for check. Exit.'
			exit 0
		;;
		esac
	;;
	self-test)
		CRONTAB_REAL="$(crontab -l 2>/dev/null)"
		if [[ $(echo $CRONTAB_REAL | grep 'TGUI SELF-TEST' | wc -l) -eq 0 ]]; then
			echo -e "$CRONTAB_REAL\n#### TGUI SELF-TEST ####\n*/5 * * * * /opt/tacacsgui/web/api/self/app.php > /dev/null 2>/dev/null &" | crontab -
			echo 1;
		else
			echo 0;
		fi
	;;
	*)
		echo 'Unexpected main argument. Exit.'
		exit 0
	;;
esac

exit 0;
