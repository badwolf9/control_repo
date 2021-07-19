ls -la /dev/mapper/|egrep "sys |data "|awk '{print $9}' | sed -r "s/.{40}//"
