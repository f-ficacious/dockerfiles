#!/bin/bash
#
declare -F getIds
declare -F createConfig
declare -F checkConfig
getIds(){
  local PUID
  local PGID
  local res
  local user

  user="$1"

  # get user id and break if user doesn't exist
  res=$( id "${user}" 2>/dev/null)
  [[ "${res}" == "" ]] && return 1

  PUID=$(echo ${res} | awk '{print $1}' | sed -E -e "s/.*=//g" -e "s/\(.*\)//g")
  PGID=$(echo ${res} | awk '{print $2}' | sed -E -e "s/.*=//g" -e "s/\(.*\)//g")

  echo "${user}: PUID=${PUID} PGID=${PGID}"

}


createConfig () {

  local msg
  local ids=()

  msg="I couldn't find a environment file. I have created a default one. Please see the README for the settings and adjust them accordingly.\nFor your convenience here are some ids that you could use:\n\n"

  # display ids for: root, docker, and the logged in user
  users=("root" "docker" $([[ ! "$USER" == "root" ]] && echo $USER))
  for user in "${users[@]}"; do msg+="$(getIds "$user")\n"; done

  cp ./env ./.env
  msg+="I have also created a sample config file. Feel free to edit this one:\n\n  nano ./.env\n\nReminder: You can display the ids again by running\n\n  ./bootstrap.sh -I\n\nExiting..."
  printf "%b\n" "${msg}"
  exit 0

}

# get config info and ask user if that is correct
# if not let user edit file and direct to readme
checkConfig(){

  declare -A config
  # reading config file into array
  for line in $(grep -E '^[^#]' ./.env)
  do
    config[${line%%=*}]="${line#*=}"
  done

  msg="This is your configuration:"
  for key in "${!config[@]}"
  do
    msg+="\n$key:\t${config[${key}]}"
  done

  printf "%b\n\n" "${msg}"

  while [[ "${loop}" == "" ]]
  do
    read -p "Do you want to continue? (y)es|no  " usr
    case "${usr,,:0:1}" in
      "y"|"") loop=1;;
  # ToDo: Give user hint to read the readme for a detailed view of the options
      "n") exit 0; loop=1;;
    esac
  done
}

# ToDo check if docker+docker-compose is installed
## if not check for system and recommend installation
#

# read folders from compose file into array
getComposeFiles() {

  local cfile
  local cfiles
  local file

  cfiles=()
  # read files from filesystem
  for file in ./*.yml
  do
    cfiles+=( "${file#*/}" )
  done

  echo "${cfiles[@]}"
}
# get all the compose files in the current folder and let the user select 1
printComposeFiles() {

  local cfile
  local files
  local i
  local loop
  local msg
  local usr


  i=0
  IFS=" " read -r -a files <<< $(getComposeFiles)

  for file in "${files[@]}"
  do
    echo "($i) ${file}"
    i=$(($i+1))
  done
} # end printComposeFiles()


# Create folders for docker volumes on file system
getLineDetail() {
  local replaceNo1
  local replaceNo2
  local str
  local type
  local prefix
  local suffix

  str="$2"
  type="$1"

  # assemble replace1 and replace 2 according to type (type, path, name)
  prefix="s/"
  suffix="//g"
  replaceNo1="${prefix}"
  replaceNo2="${prefix}"

  case "${type}" in
    "type" ) replaceNo1+="_PATH.+.+"
           replaceNo2+="^.+\{"
           ;;
    "path" ) replaceNo1+=".+=\""
           replaceNo2+="^.+:\-"
           replaceNo3="${prefix}\}.+${suffix}"
           ;;
    "name" ) replaceNo1+=".+\}"
           replaceNo2+="^.+:\-"
           ;;
  esac

  replaceNo1+="${suffix}"
  replaceNo2+="${suffix}"

  echo "${str}" | sed -E -e "${replaceNo1}" -e "${replaceNo2}" -e "$replaceNo3"

}


getFolderInfo(){

  local file
  local arr

  arr=""

  file="$1"
  #[[ ! "${file##*.}" == "env" ]] && needle="device" || needle="PATH"
  # open file and grep lines
  #folders=($(grep "${needle}" ${file} | sed -E -e 's/.*\{//g' -e 's/"$//g' | sort))
  folders=($(grep "PATH" ${file} | sed -E -e 's/.*\{//g' -e 's/"$//g' | sort))

  for line in "${folders[@]}"
  do
    [[ "${line:0:1}" == "#" ]] && continue
    retType=$(getLineDetail "type" "${line}")
    retPath=$(getLineDetail "path" "${line}")
    retName=$(getLineDetail "name" "${line}")
    # return string
    ret="${retType}|${retPath}"
    # if not .env file add also folder name
    [[ ! "${file##*.}" == "env" ]] && ret+="|${retName}"

    # get config values

    arr+="${ret}#"
  done
  echo "${arr}"
}

# creating a folder on the local filesystem
createFolder() {
  local folder

  folder="$1"

  if [[ ! -d "${folder}" ]]
  then
    mkdir -p "${folderDetails[1]}${folderDetails[2]}"
    ret=$?
    [[ $ret -eq 0 ]] && msg="[success]" || msg="[error]"
    msg+=" Creating ${folder}"
  else
    msg="Folder already exists: ${folder}"
  fi
  echo "${msg}"
  [[ ! ${ret} -eq 0 ]] && exit 1
}


### BEGIN SCRIPT

# check config file
[ ! -f "./.env" ] && createConfig || checkConfig

# print message for user which compose files are available
msg="Which file do you want to use today?"
printComposeFiles

IFS=" " read -r -a files <<< $(getComposeFiles)

# get user input and check for sanity
while [[ "${loop}" == "" ]]
do
  read -p "Please select a file from the list: " usr

  # if the user enter a number, save that as the file
  [[ ${usr} =~ ^[0-9]+$ ]] && [[ ${usr} -lt ${#files[@]} ]] && echo "You selected via number: ${file}" && cfile="${files[${usr}]}" && loop=1

  # if the user typed the filename check that
  for file in "${files[@]}"
  do
    [[ "${usr,,}" == "${file,,}" ]] && echo "You selected via name: ${file}" && cfile="${file}" && loop=1
  done
done

# Getting Config Values from .env
IFS="#" read -r -a confs <<< $(getFolderInfo "./.env")

declare -A userConfig
for line in "${confs[@]}"
do
  userConfig["${line%%|*}"]="${line#*|}"
done

# Getting values from Docker compose file and override with values from config file
IFS="#" read -r -a composeFileFolders <<< "$(getFolderInfo "./media.yml")"
for folder in "${composeFileFolders[@]}"
do
  # converting the string of the line into an array
  # [0] = type, [1] = path, [2] = name
  IFS="|" read -r -a folderDetails <<< "${folder}"

  [[ ! "${userConfig[${folderDetails[0]}]}" == "" ]] && folderDetails[1]="${userConfig[${folderDetails[0]}]}"

  # create folders on file system
  createFolder "${folderDetails[1]}${folderDetails[2]}"
done

# start docker compose or end script
loop=0
while [[ ${loop} -eq 0 ]]
do
  read -p "Do you want to automatically create all docker containers? (y)es|no " usr
  case "${usr,,:0:1}" in
   "y"|"" ) echo "composing"
     loop=1;;
   "n") echo "Good bye"
     exit 0;;
  esac
done
