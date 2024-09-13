#!/bin/bash

# ROOT_PATH="/opt/tgui_data"
ISO_DATE=$(date '+%Y-%m-%d')

if [ $# -eq 0 ]
then
echo '#######################################################################'
echo '###########################Instruction#################################'
echo '#######################################################################'
echo '#######################################################################'
echo -e '$\n'
exit 0
fi

get_last_revision() {
	local db_type=$1

	local func_revision_last_one=$(ls -tr "/opt/tgui_data/backups/database/" | grep "$db_type" | tail -n 1 | xargs)
	local func_revision_last_one_number=$(echo "$func_revision_last_one" | sed -r 's/.*_([0-9]*)\..*/\1/g' | xargs)
	local func_revision=$(echo "$func_revision_last_one_number" | tr -d '[:space:]' | xargs)

	echo "$func_revision"
}

case $1 in
	check)
		OUTPUT=""
		if [ ! -d /opt/tgui_data/backups/database/ ]
			then
				echo "Dir backups/database doesn't exist. Creating."
				mkdir -p /opt/tgui_data/backups/database/
				find /opt/tgui_data/backups -type d -exec chmod 750 {} \;
		fi
		if [ ! -d /opt/tgui_data/backups/api/ ]
			then
				echo "Dir backups/api doesn't exist. Creating."
				mkdir -p /opt/tgui_data/backups/api/
				find /opt/tgui_data/backups -type d -exec chmod 750 {} \;
		fi
		if [ ! -d /opt/tgui_data/backups/gui/ ]
			then
				echo "Dir backups/gui doesn't exist. Creating."
				mkdir -p /opt/tgui_data/backups/gui/
				find /opt/tgui_data/backups -type d -exec chmod 750 {} \;
		fi
	;;
	diff)
		NEW=''
		OLD=''
		REVISION=$3
		DBTYPE=$2
		LISTDB_FOR_DIFF=$(ls -utr /opt/tgui_data/backups/database/ | grep "$DBTYPE" | tail -n 2)
		#if [ -z "$REVISION" ]; then
			for ITEM in "$LISTDB_FOR_DIFF"
				do
					if [[ "$OLD" = "" ]]; then
						OLD=$ITEM
					else
						NEW=$ITEM
					fi
				done
			if [[ "$OLD" = "" ]]; then
				echo 999
				exit 1
			fi
			if [[ "$NEW" = "" ]]; then
				echo 999
				exit 1
			fi
			NEW_FOR_DIFF="/opt/tgui_data/backups/database/${NEW}"
			OLD_FOR_DIFF="/opt/tgui_data/backups/database/${OLD}"
			diff -I "Dump completed" "$NEW_FOR_DIFF" "$OLD_FOR_DIFF"
	;;
	removeLast)
		LISTDB_FOR_RMLAST=$(ls -utr /opt/tgui_data/backups/database/ | grep "$DBTYPE" | tail -n 1)
		LASTDB_TO_REMOVE="/opt/tgui_data/backups/database/${LISTDB_FOR_RMLAST}"
		rm "$LASTDB_TO_REMOVE"
	;;
	make)
		# $2 username $3 password $4 DBname $5 tables list $file name
		export MYSQL_PWD=$3
		END_OF_NAME=$5
		REVISION=$6
		if [ -z "$END_OF_NAME" ]; then
			END_OF_NAME="all"
		fi
		if [ -z "$REVISION" ]; then
			REVISION=0
		fi
		TABLES=$5
		TYPE=""
		if [ "$TABLES" = "full" ]; then
			TYPE=$TABLES
			REVISION=$(get_last_revision "$TYPE")
			if [[ "$REVISION" = "" ]]; then
				REVISION=1
			else
				((++REVISION))
			fi
			TABLES=""
		elif [ "$TABLES" = "tcfg" ]; then
			TYPE=$TABLES
			TABLES="--tables "$(mysql -u $2 -D $4 -Bse \
"show tables where Tables_in_tgui like 'tac\_%' or Tables_in_tgui like 'mavis\_%' \
or Tables_in_tgui like 'ldap\_%' or Tables_in_tgui like 'obj\_%' or Tables_in_tgui like 'bind\_%'" 2>/dev/null | xargs)
		elif [ "$TABLES" = "tlog" ]; then
			TYPE=$TABLES
			TABLES="--tables tac_log_accounting tac_log_authorization tac_log_authentication"
		elif [ "$TABLES" = "apicfg" ]; then
			TYPE=$TABLES
			REVISION=$(get_last_revision "$TYPE")
			if [[ "$REVISION" = "" ]]; then
				REVISION=1
			else
				((++REVISION))
			fi
			TABLES="--tables $(mysql -u $2 -D $4 -Bse "show tables where Tables_in_tgui like 'api\_%'" 2>/dev/null | xargs)"
		elif [ $TABLES = "api_log" ]; then
			TYPE=$TABLES
			TABLES="api_logging"
		fi
		umask 111
		BACKUPFILE_PATH="/opt/tgui_data/backups/database/${ISO_DATE}_${END_OF_NAME}_${REVISION}.sql"
		mysqldump -u $2 $4 $TABLES > "${BACKUPFILE_PATH}" 2>&1
		chmod 640 "${BACKUPFILE_PATH}"
		# DELETE 21-30
		LAST_NINE_BACKUPS=$(ls -uvr /opt/tgui_data/backups/database/ | grep "$TYPE" | tail -n +21)
		for FILES_TO_BE_DELETE in "${LAST_NINE_BACKUPS}"; do
			rm "/opt/tgui_data/backups/database/${FILES_TO_BE_DELETE}"
		done
		REVISION=0
		unset MYSQL_PWD
		echo "done"
	;;
	datatables)
		ORDER=$2
		DTTYPE=$3
		if [ -z "$DTTYPE" ]; then
			DTTYPE='tcfg'
		fi

		if [ -z "$START" ]; then
			START=1
		fi

		if [ -z "$LENGTH" ]; then
			LENGTH=10
		fi
		if [ "$ORDER" = "asc" ]; then
			ORDER=""
		else
			ORDER='-r'
		fi

		if [ $DTTYPE = "full" ]; then
			DB_COUNT_FULL=$(ls -luv /opt/tgui_data/backups/database/ | grep "full" | wc -l)
			if [ "$ORDER" = "" ]; then
				DB_COUNT_FULL_SL=$(ls -luv /opt/tgui_data/backups/database/ | grep "full" | tail -n +"$START" | head -n "$LENGTH" | wc -l)
			else
				DB_COUNT_FULL_SL=$(ls -luvr /opt/tgui_data/backups/database/ | grep "full" | tail -n +"$START" | head -n "$LENGTH" | wc -l)
			fi
			echo "${DB_COUNT_FULL};${DB_COUNT_FULL_SL}"
			if [ "$ORDER" = "" ]; then
				LISTDB_TYPE_FULL=$(ls -luv /opt/tgui_data/backups/database/ | grep "full" | awk '{print $9,$5}' | xargs)
			else
				LISTDB_TYPE_FULL=$(ls -luvr /opt/tgui_data/backups/database/ | grep "full" | awk '{print $9,$5}' | xargs)
			fi
			echo "${LISTDB_TYPE_FULL}"
			echo "done"
			exit 0
		fi

		DB_COUNT_STANDARD=$(ls -l /opt/tgui_data/backups/database/ | grep $DTTYPE | grep -v total | wc -l)
        DB_COUNT_STANDARD_SL=$(ls -luv $ORDER /opt/tgui_data/backups/database/ | grep "$DTTYPE" | grep -v total | tail -n +"$START" | head -n "$LENGTH" | wc -l)
        echo "${DB_COUNT_STANDARD};${DB_COUNT_STANDARD_SL}"
		if [ "$ORDER" = "" ]; then
			LISTDB_TYPE_STANDARD=$(ls -luv /opt/tgui_data/backups/database/ | grep "$DTTYPE" | grep -v total | awk '{print $9,$5}'| xargs)
		else
			LISTDB_TYPE_STANDARD=$(ls -luvr /opt/tgui_data/backups/database/ | grep "$DTTYPE" | grep -v total | awk '{print $9,$5}'| xargs)
		fi
		echo "${LISTDB_TYPE_STANDARD}"
		find /opt/tgui_data/backups/database -type f -exec chmod 640 {} \;
		echo "done"
	;;
	delete)
		rm "/opt/tgui_data/backups/database/${2}"
		echo 1
	;;
	restore)
		export MYSQL_PWD=$3
		mysql -u $2 $4 < "/opt/tgui_data/backups/database/${5}"
		unset MYSQL_PWD
		echo 1
	;;
	*)
		echo 'Unexpected argument. Exit.'
		exit 0
	;;
esac

exit 0