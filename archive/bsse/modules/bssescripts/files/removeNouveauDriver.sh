echo 0 > /sys/class/vtconsole/vtcon1/bind
rmmod nouveau
test -f /etc/init.d/consolefont && /etc/init.d/consolefont restart
rmmod ttm
rmmod drm_kms_helper
rmmod drm
