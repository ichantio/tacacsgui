#!/bin/bash

TEMP_FOLDER='/opt/tacacsgui/temp'
GIT_REPO_PATH='/opt/tgui_data/confManager/configs'
GIT_REPO_PATH_REGEX='\/opt\/tgui_data\/confManager\/configs\/'

CONTEXT='3'
MV_FROM=''
FILE_B=''
NEW_DIR_NAME=''
OLD_FILENAME_NAME=''
FILENAME_EXPORT=''
COMM_START='0'
COMM_END='0'

function usage()
{
    echo -e "\t-h --help"
    echo -e "\t--info=filename"
    echo -e "\t--mkdir=dir_name"
    echo -e "\t--commit-list=filename"
    echo -e "\t--delete=filename"
    echo -e "\t--show=hash:filename"
    echo -e "\t--diff=hash1:hash2:filename"
    echo -e "\t--mv-from=filename --mv-to=filename"
    echo -e "\t--mv-bunch-from=filename --mv-bunch-to=filename"
    echo -e "\t--debug=$DEBUG|1"
    echo ""
}

function getInfo() {
  VERSION_COUNT=$(git -C ${GIT_REPO_PATH} log --follow --format="%h" -- $1 | wc -l)
  FILE_COMM_DATE=$( git -C ${GIT_REPO_PATH} log -1 --format='%ct' -- $1 )
  echo "${VERSION_COUNT} ${FILE_COMM_DATE}"
  return
}

if [ $# -eq 0 ]
then
	usage
	exit
fi

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --info)
            echo -n $( getInfo $VALUE )
            exit
            ;;
        --commit-start)
            COMM_START=$VALUE
            ;;
        --commit-end)
            COMM_END=$VALUE
            ;;
        --commit-list)
            count='0';
            echo "$(git -C ${GIT_REPO_PATH} log --format="%ct %h" -- ${VALUE} | cat | sed -r '/^\s*$/d')"
            exit
            ;;
        --show)
            echo -n "$(git -C ${GIT_REPO_PATH} show ${VALUE} | cat)"
            exit
            ;;
        --show-redirect)
            IFS=':' read HASH FILENAME <<< "$VALUE"
            echo -n "$(git -C ${GIT_REPO_PATH} show ${VALUE} | cat)" > $TEMP_FOLDER'/'$FILENAME_EXPORT'_'$HASH && echo $FILENAME_EXPORT'_'$HASH || echo 0;
            exit
            ;;
        --set-filename)
            FILENAME_EXPORT=$VALUE
            ;;
        --context)
            CONTEXT=$VALUE
            ;;
        --full-file)
            if [[ $VALUE -eq '1' ]]; then
              CONTEXT='0'
            fi
            ;;
        --file-b)
            FILE_B="$VALUE"
            #echo $FILE_B
            ;;
        --diff)
            IFS=':' read HASH_A HASH_B FILENAME <<< "$VALUE"
            if [[ ${FILE_B} == '' ]]; then
              FILE_B="$FILENAME"
            fi
            if [[ $CONTEXT -eq '0' ]]; then
              CONTEXT=$(echo -en "$(git -C ${GIT_REPO_PATH} show ${HASH_B}:${FILENAME} | wc -l)\n$(git -C ${GIT_REPO_PATH} show ${HASH_A}:${FILE_B} | wc -l)" | sort -nr | head -n 1)
            fi

            echo -n "$(git -C ${GIT_REPO_PATH} diff -M -U${CONTEXT} ${HASH_A} ${HASH_B} -- ${FILENAME} ${FILE_B} )"
            #--word-diff
            exit
            ;;
        --delete)
            if [[ $(git -C ${GIT_REPO_PATH} rm -r --force $VALUE 2>/dev/null | wc -l) -gt 0 ]]; then
              echo -n "1"
            else
              rm -r --interactive=never "${GIT_REPO_PATH}/${VALUE}" && echo -n "1"
              #echo -n "0"
            fi
            exit
            ;;
        --mv-from)
            MV_FROM="${GIT_REPO_PATH}/${VALUE}"
            ;;
        --mv-to)
            mv $MV_FROM "${GIT_REPO_PATH}/${VALUE}"
            exit
            ;;
        --mv-bunch-from)
            OLD_FILENAME_NAME=$VALUE
            ;;
        --mv-bunch-to)
            FIND_CMD='find /opt/tgui_data/confManager/configs/ -name "'$OLD_FILENAME_NAME'__*" -type f -not -path "*\.git*" -printf "%h %f\n"'
            eval $FIND_CMD | while read find_file; do
              IFS=' ' read path filename_old <<< "$find_file"
              mv "${path}/${filename_old}" ${path}'/'${VALUE}${filename_old#${OLD_FILENAME_NAME}}
              git -C ${GIT_REPO_PATH} add ${path}'/'${VALUE}${filename_old#${OLD_FILENAME_NAME}}
              git -C ${GIT_REPO_PATH} rm -r "${path}/${filename_old}"
            done
            exit
            ;;
        --debug)
            DEBUG=$VALUE
            ;;
        --mkdir)
            mkdir "${GIT_REPO_PATH}/${VALUE}" 2>/dev/null && echo 1 || echo 0
            ;;
        --deldir)
            if [[  $(ls -ld ${GIT_REPO_PATH}/${VALUE}/* | wc -l) == 0 ]]; then
              rm -rf "${GIT_REPO_PATH}/${VALUE}" 2>/dev/null && echo 1 || echo 0
            else
              echo 2
            fi
            ;;
        --new-dir-name)
            NEW_DIR_NAME=${VALUE}
            ;;
        --mv-dir)
            if [[ $NEW_DIR_NAME == '' ]]; then
              echo 0
              exit
            fi
            if [[ $(ls -ld "${GIT_REPO_PATH}/${NEW_DIR_NAME}" 2>/dev/null | wc -l ) != 0 ]]; then
              echo 2
              exit
            fi
            mv ${GIT_REPO_PATH}/${VALUE} ${GIT_REPO_PATH}/${NEW_DIR_NAME} 2>/dev/null && echo 1 || echo 0
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done
