#!/bin/bash
# Backup all of the R&D systems
# Designed for Mac OS X
NOW=$(date)
LOGFILE=/Users/brianb/logs/RDBackup.log
echo $NOW >>$LOGFILE
echo "  Starting Backup" >>$LOGFILE
ssh root@adht2 '/root/backup_sql.sh'
cd /Users/brianb/Downloads/RDBackup/
# Backup ADHT2
echo "  Backing up adht2/var/XOI" >>$LOGFILE
rsync -avlr --delete --stats --progress root@adht2:/var/XOI/* adht2/var/XOI
echo "  Backing up adht2/var/www" >>$LOGFILE
rsync -avlr --delete --stats --progress root@adht2:/var/www/* adht2/var/www
echo "  Backing up adht2/var/SQL" >>$LOGFILE
rsync -avlr --delete --stats --progress root@adht2:/var/SQL/* adht2/var/SQL

# Now backup ADHT1
echo "  Backing up adht1/var/www" >>$LOGFILE
rsync -avlr --delete --stats --progress root@adht1:/var/www/* adht2/var/www

# Now backup RDDEV
echo "  Backing up rddev/home/rd" >>$LOGFILE
rsync -avlr --delete --stats --progress rd@rddev:/home/rd/* rddev/home/rd
echo "  Backing up rddev/var/www/viewgit" >>$LOGFILE
rsync -avlr --delete --stats --progress rd@rddev:/var/www/viewgit/* rddev/var/www/viewgit

# Now tgz it up
cd ..
# Save off the old one, just in case
mv RDBackup.tgz RDBackup.tgz.old
echo "  Tarring it all up" >>$LOGFILE
tar -zcvf RDBackup.tgz RDBackup

# Check if Bluedot/ProEng is Mounted
if [ ! -d "/Volumes/ProEng" ]; then
	mkdir /Volumes/ProEng
fi
# Check if it's REALLY mounted, or if the directory is just hanging out...
if [ ! "$(ls -A /Volumes/ProEng)" ]; then
	~/mount_proeng.sh
fi 
echo "  Copying over to Bluedot" >>$LOGFILE
cp RDBackup.tgz /Volumes/ProEng/
NOW=$(date)
echo $NOW >>$LOGFILE
echo "  Finishing Backup" >>$LOGFILE
