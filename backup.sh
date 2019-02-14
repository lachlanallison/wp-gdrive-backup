export PATH=${PATH}:<add gdrive location path>
db_user="<add db username>"
db_pass="<add db password>"
backup_file="<add prefix for backup file>"
backup_dir="<add google folder for backups>"

cd ~/backups

mysqldump --user=$db_user --password=$db_pass --all-databases > ${backup_file}_db_dump.sql

DOW=$(date +%u)
WOY=$(date +%V)
if [ $DOW == '1' ]; then
  filename="${backup_file}_wk_${DOW}_${WOY}.tgz"
else
  filename="${backup_file}_${DOW}.tgz"
fi

backup_dir_id=`gdrive list --query "'root' in parents" | grep $backup_dir | awk '{print $1}'`
#echo $backup_dir_id
crnt_file_id=`gdrive list --query "'${backup_dir_id}' in parents"| grep $filename | awk '{print $1}'`
#echo $crnt_file_id

if [ -z "$crnt_file_id" ]; then
  echo "No file to delete"
else
  for i in $crnt_file_id; do
	echo "Deleting file - ${i}"
    gdrive delete $i
  done
fi

tar czf $filename <list files to tar and gzip> ~/backups/wp_db_dump.sql

gdrive upload --parent $backup_dir_id $filename
