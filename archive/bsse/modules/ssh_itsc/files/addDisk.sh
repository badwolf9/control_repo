#!/bin/bash
# Select the disk device and chose a label for the partition
# ptype=msdos for disks up to 2 TB. ptype=gpt for disks over 2 TB

disk=$1;
label=DATA;
ptype=gpt;
fs=ext4;

if [[ $disk == '' ]]; then
        echo "no disk selected";
        exit 1;
fi

if [[ $disk == `df / | grep "/dev/" | awk '{print $1}' | sed s'/.$//'` ]]; then
        echo "choosen disk is mounted as /";
        exit 1;
fi

# print the current partition(s) state
echo
echo -e "\033[32mlist current installed disks ...\033[0m"
parted -l

echo -e "\033[32mcreate partition on this disk\033[31m"
echo
parted -s $disk print ;
echo -e "\033[0m"

echo -e "\033[32mdisk\033[0m:       \033[31m "$disk"\033[0m "
echo -e "\033[32mpart-type\033[0m:  \033[31m "$ptype"\033[0m "
echo -e "\033[32mlabel\033[0m:      \033[31m "$label"\033[0m "
echo -e "\033[32mfilesystem\033[0m: \033[31m "$fs"\033[0m "

echo -n "start with this parameters? (y/n) "
read a
if [[ $a == "N" || $a == "n" ]]; then
        echo "stop ...";
        exit 1;
else
        echo "make it so ...";
fi


# create a gpt ot msdos partition table (depending on $ptype variable defined above)
parted -s -a optimal $disk mklabel $ptype

if [ $? -eq 0 ]; then
        echo "successfully created partition table";
        sleep 5;
else
        echo "Could not create partition table";
        exit 1;
fi

# create the partition, starting at 1MB which may be better
# with newer disks
parted -a optimal -- $disk unit compact mkpart primary ext4 "1" "-1" ; sleep 5

# format it
mkfs.$fs -v -L "$label" ${disk}1 && echo "OK. That's it"

mkdir /local1

# find UUID and make an entry in /etc/fstab
UUID=$(tune2fs ${disk}1 -l | grep UUID | awk '{print $3}')

echo -n "UUID: "
echo $UUID

echo "UUID=$UUID /local1                 $fs    defaults        1 2" >> /etc/fstab

# show results and mount new disk
cat /etc/fstab
mount -a
df -h
