#!/bin/bash
if [ `cat /var/log/originalSshCommand.log|wc -l` -gt 1000 ];then
    /bin/date > /var/log/originalSshCommand.log
else 
    /bin/date >> /var/log/originalSshCommand.log
fi

echo $SSH_ORIGINAL_COMMAND >> /var/log/originalSshCommand.log
case `echo $SSH_ORIGINAL_COMMAND | awk '{print $1 " " $2 " " $3}'` in
    "who -s -u") $SSH_ORIGINAL_COMMAND
    ;;
    "uname -s -s") $SSH_ORIGINAL_COMMAND
    ;;
    "shutdown -h now") $SSH_ORIGINAL_COMMAND
    ;;
    "shutdown -i5 -y") $SSH_ORIGINAL_COMMAND
    ;;
    "svnserve -t ") $SSH_ORIGINAL_COMMAND
    ;;
    "virsh list --all") $SSH_ORIGINAL_COMMAND
    ;;
    "virsh -r dominfo") $SSH_ORIGINAL_COMMAND
    ;;
    "iscsiadm -m session") $SSH_ORIGINAL_COMMAND
    ;;
    "rsync --server --sender") $SSH_ORIGINAL_COMMAND
    ;;
    "/root/bin/manageHomeDir.sh -p -n") $SSH_ORIGINAL_COMMAND
    ;;
    "/root/bin/manageScuWorkingDir.sh -p -n") $SSH_ORIGINAL_COMMAND
    ;;
    "/root/bin/manageGrid.sh -p -n") $SSH_ORIGINAL_COMMAND
    ;;
    "rsync --server -vlogDtpr") $SSH_ORIGINAL_COMMAND
    ;;
    "rsync --server -vlogDtpre.is") $SSH_ORIGINAL_COMMAND
    ;;
    "rsync --server -logDtpre.iLs") $SSH_ORIGINAL_COMMAND
    ;;
    "rsync --server -logDtpre.iLsf") $SSH_ORIGINAL_COMMAND
    ;;
    "rsync --server -vlogDtpre.iLs") $SSH_ORIGINAL_COMMAND
    ;;
    "rsync --server -logDtpre.is") $SSH_ORIGINAL_COMMAND
    ;;
    "rsync --server -vlogDtpre.iLsfx") $SSH_ORIGINAL_COMMAND
    ;;
    "scp -t jira-db.dmp") $SSH_ORIGINAL_COMMAND
    ;; 
    "scp -t crowd-db.dmp") $SSH_ORIGINAL_COMMAND
    ;; 
    "scp -t /tmp") $SSH_ORIGINAL_COMMAND
    ;; 
    "scp -t confluence-db.dmp") $SSH_ORIGINAL_COMMAND
    ;; 
    "scp -t bin/shareGroupsFromSsvr05.sh") $SSH_ORIGINAL_COMMAND
    ;; 
    "scp -t bin/shareGroupsFromSsvr07.sh") $SSH_ORIGINAL_COMMAND
    ;;
    "ps -e -f") $SSH_ORIGINAL_COMMAND
    ;;
    "scp -t /tmp") $SSH_ORIGINAL_COMMAND
    ;;
    "/usr/sbin/zfs list -t") $SSH_ORIGINAL_COMMAND
    ;; 
    "/sbin/zfs list -t") $SSH_ORIGINAL_COMMAND
    ;; 
    "zfs list -t") $SSH_ORIGINAL_COMMAND
    ;; 
    "/usr/sbin/zfs recv -F") $SSH_ORIGINAL_COMMAND
    ;;
    "/sbin/zfs recv -F") $SSH_ORIGINAL_COMMAND
    ;;
    "zfs recv -F") $SSH_ORIGINAL_COMMAND
    ;;
    "/usr/local/itsc/solaris/bin/mbuffer -q -s") eval $SSH_ORIGINAL_COMMAND
    ;;
    ": : :") :
    ;;
    "zpool status dataPool") $SSH_ORIGINAL_COMMAND
    ;;
    *) echo "Command: $SSH_ORIGINAL_COMMAND not authorized" >> /var/log/originalSshCommand.log
    ;;
esac
