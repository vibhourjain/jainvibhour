BASE_FOLDER="/user/OS_UPGRADE/"

LOG_FILE =$BASE_FOLDER/$(hostname)_pre_upgrade_task_script.log
exec > "$LOG_FILE" 2>&1

#Check for the root user
if [ "$(id -u)" != "0" ]; then
 echo "This script must be run as root"
 exit 1
fi

#Capture Start time
start_time=$(date +%s)

#Create Backup directory
BACKUP_DIR=$BASE_FOLDER/$(hostname)


#list network interfaces
nic_list=$(ip -o link show | awk -F': ' '{print $2}')

