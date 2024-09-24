#!/bin/bash

PATH_TACLOG='/var/log/tacacsgui'
PATH_PHPPARSER='/opt/tacacsgui'
ACC_FILTER_FILE='/opt/tgui_data/parser/acc-filter.txt'
AUTHE_FILTER_FILE='/opt/tgui_data/parser/authe-filter.txt'
AUTHO_FILTER_FILE='/opt/tgui_data/parser/autho-filter.txt'

if [ $# -eq 0 ]
then

echo '#######################################################################'
echo '###########################Instruction#################################'
echo '#######################################################################'
echo '#######################################################################'$'\n'
exit 0

elif [ $# -eq 1 ]
then
LOG_TYPE=$1

elif [ $# -gt 1 ]
then
echo "Too match arguments! Exit."
exit 0
fi

#read LOG_LINE;
# Get accounting filter:
if [ -f "${ACC_FILTER_FILE}" ]; then
	if [ $(grep -v '^#\|^\s*$\|^\s*#' "${ACC_FILTER_FILE}" | wc -l) -eq 0 ]; then
		COMBINED_PATTERNS="^ACCPATTERN-FOR-FILTER-DOES-NOT-EXIST$"
	else
		while read -r accpattern; do
			# Skip empty lines and comments
			[[ -z "$accpattern" || "$accpattern" =~ ^# ]] && continue
			ACCPATTERNS+=("$accpattern")
		done < "${ACC_FILTER_FILE}"
		COMBINED_PATTERNS=$(IFS="|"; echo "${ACCPATTERNS[*]}")
	fi
else
	COMBINED_PATTERNS="^ACCPATTERN-FOR-FILTER-DOES-NOT-EXIST$"
fi
# readarray -t ACCPATTERNS < /opt/tgui_data/parser/acc-filter.txt
# COMBINED_ACCPATTERNS=$(IFS="|"; echo "${ACCPATTERNS[*]}")
# Get authentication filter:
if [ -f "${AUTHE_FILTER_FILE}" ]; then
    if [ $(grep -v '^#\|^\s*$\|^\s*#' "${AUTHE_FILTER_FILE}" | wc -l) -eq 0 ]; then
		COMBINED_AUTHEPATTERNS="^AUTHEPATTERN-FOR-FILTER-DOES-NOT-EXIST$"
	else
		while read -r authepattern; do
			# Skip empty lines and comments
			[[ -z "$authepattern" || "$authepattern" =~ ^# ]] && continue
			AUTHEPATTERNS+=("$authepattern")
		done < "${AUTHE_FILTER_FILE}"
		COMBINED_AUTHEPATTERNS=$(IFS="|"; echo "${AUTHEPATTERNS[*]}")
	fi
else
  COMBINED_AUTHEPATTERNS="^AUTHEPATTERN-FOR-FILTER-DOES-NOT-EXIST$"
fi
# readarray -t AUTHEPATTERNS < /opt/tgui_data/parser/authe-filter.txt
# COMBINED_AUTHEPATTERNS=$(IFS="|"; echo "${AUTHEPATTERNS[*]}")
# Get authorization filter:
if [ -f "${AUTHO_FILTER_FILE}" ]; then
	if [ $(grep -v '^#\|^\s*$\|^\s*#' "${AUTHO_FILTER_FILE}" | wc -l) -eq 0 ]; then
		COMBINED_AUTHOPATTERNS="^AUTHOPATTERN-FOR-FILTER-DOES-NOT-EXIST$"
	else
		while read -r authopattern; do
			# Skip empty lines and comments
			[[ -z "$authopattern" || "$authopattern" =~ ^# ]] && continue
			AUTHOPATTERNS+=("$authopattern")
		done < "${AUTHO_FILTER_FILE}"
		COMBINED_AUTHOPATTERNS=$(IFS="|"; echo "${AUTHOPATTERNS[*]}")
	fi
else
  COMBINED_AUTHOPATTERNS="^AUTHOPATTERN-FOR-FILTER-DOES-NOT-EXIST$"
fi
# readarray -t AUTHOPATTERNS < /opt/tgui_data/parser/autho-filter.txt
# COMBINED_AUTHOPATTERNS=$(IFS="|"; echo "${AUTHOPATTERNS[*]}")

case $1 in
	accounting)
		if [ ! -d $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/accounting/ ]
			then
				echo "Dir doesn't exist. Creating."
				mkdir -p $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/accounting/;
				chown www-data:www-data $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/accounting/;
				chmod 750 $(find $PATH_TACLOG/tac_plus -type d);
		fi
		while read LINE; do
			if [ ! -f $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/accounting/$(date +%Y-%m-%d)-accounting.log ]
				then
				echo "File doesn't exist. Creating."
				echo "###The beginning of file###" > $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/accounting/$(date +%Y-%m-%d)-accounting.log
				chown www-data:www-data $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/accounting/$(date +%Y-%m-%d)-accounting.log;
				chmod 640 $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/accounting/$(date +%Y-%m-%d)-accounting.log;
			fi
			if [[ $LINE =~ $COMBINED_ACCPATTERNS ]]
				then
					continue
			else
				echo $LINE >> $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/accounting/$(date +%Y-%m-%d)-accounting.log;
				php $PATH_PHPPARSER/parser/parser.php $1 "${LINE}"
			fi
		done
	;;
	authorization)
		echo "2222"
		if [ ! -d $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authorization/ ]
			then
				mkdir -p $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authorization/;
				chown www-data:www-data $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authorization/;
				chmod 750 $(find $PATH_TACLOG/tac_plus -type d);
        fi
		while read LINE; do
			if [ ! -f $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authorization/$(date +%Y-%m-%d)-authorization.log ]
				then
				echo "###The beginning of file###" > $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authorization/$(date +%Y-%m-%d)-authorization.log;
				chown www-data:www-data $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authorization/$(date +%Y-%m-%d)-authorization.log;
				chmod 640 $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authorization/$(date +%Y-%m-%d)-authorization.log;
			fi
			if [[ $LINE =~ $COMBINED_AUTHOPATTERNS ]]
				then
					continue
			else
				echo $LINE >> $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authorization/$(date +%Y-%m-%d)-authorization.log;
				php $PATH_PHPPARSER/parser/parser.php $1 "${LINE}"
			fi
		done
	;;
	authentication)
		echo "3333"
		if [ ! -d $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authentication/ ]
			then
				mkdir -p $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authentication/;
				chown www-data:www-data $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authentication/;
				chmod 750 $(find $PATH_TACLOG/tac_plus -type d);
		fi
		while read LINE; do
			if [ ! -f $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authentication/$(date +%Y-%m-%d)-authentication.log ]
				then
				echo "###The beginning of file###" > $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authentication/$(date +%Y-%m-%d)-authentication.log;
				chown www-data:www-data $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authentication/$(date +%Y-%m-%d)-authentication.log;
				chmod 640 $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authentication/$(date +%Y-%m-%d)-authentication.log;
			fi
			if [[ $LINE =~ $COMBINED_AUTHEPATTERNS ]]
				then
					continue
			else
				echo $LINE >> $PATH_TACLOG/tac_plus/$(date +%Y)/$(date +%m)/authentication/$(date +%Y-%m-%d)-authentication.log;
				php $PATH_PHPPARSER/parser/parser.php $1 "${LINE}"
			fi
		done
	;;
	*)
		echo 'Unexpected argument. Exit.'
		exit 0
	;;
esac

exit 0;
