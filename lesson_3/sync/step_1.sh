# /bin/bash
#sudo bash<<-'SUDO' 
crontab -r && echo "crontab wipe SUCCESS" || echo "crontab wipe FAIL"
crontab -l
logfile="/var/log/vagrant_custom.log"
wipefs --all --force /dev/VolGroup00/LogVol00
lvremove -f /dev/VolGroup00/LogVol00
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
mkfs.xfs -f /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt && echo "mount SUCCESS" || echo "mount FAIL"
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i && echo "mount $i SUCCESS" || echo "mount $i FAIL"; done
#echo "@reboot sleep 30 && sudo bash /home/vagrant/sync/step_2.sh  2>&1 >> $logfile" | crontab - && echo "crontab update SUCCESS" || echo "crontab update FAIL"
chroot /mnt/  <<-'CHROOT' 
	echo "@reboot sleep 30 && sudo bash /home/vagrant/sync/step_2.sh  2>&1 >> /var/log/vagrant_custom.log" | crontab - && echo "crontab update SUCCESS" || echo "crontab update FAIL"
	grub2-mkconfig -o /boot/grub2/grub.cfg
	cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
	CHROOT
reboot
#SUDO

