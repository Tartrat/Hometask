# /bin/bash
#sudo -s <<-'SUDO'
logfile="/var/log/vagrant_custom.log"
wipefs --all --force /dev/vg_root/lv_root
lvremove -f /dev/vg_root/lv_root && echo "lvremove vg_root SUCCESS" || echo "lvremove vg_root  FAIL"
vgremove -f /dev/vg_root && echo "vgremove vg_root SUCCESS" || echo "vgremove vg_root  FAIL"
pvremove -f /dev/sdb && echo "pvremove /dev/sdb SUCCESS" || echo "pvremove /dev/sdb  FAIL"
pvcreate /dev/sdc /dev/sdd 
vgcreate vg_var /dev/sdc /dev/sdd
lvcreate -L 950M -m1 -n lv_var vg_var
mkfs.ext4 /dev/vg_var/lv_var 
mount /dev/vg_var/lv_var /mnt && echo "mount /dev/vg_var/lv_var to /mnt SUCCESS" || echo "mount /dev/vg_var/lv_var to /mnt FAIL"
cp -aR /var/* /mnt/ && echo "cp /var/* /mnt/ SUCCESS" || echo "cp /var/* /mnt/ FAIL"
rm -rf /var/* && echo "rm /var/* /mnt/ SUCCESS" || echo "rm /var/* /mnt/ FAIL"
umount /mnt && echo "umount SUCCESS" || echo "umount FAIL"
mount /dev/vg_var/lv_var /var && echo "mount /dev/vg_var/lv_var to /var SUCCESS" || echo "mount /dev/vg_var/lv_var to /var FAIL"
echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab   && echo "update fstab SUCCESS" || echo "update fstab FAIL"
lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol_Home
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/ && echo "cp /home/* /mnt/ SUCCESS" || echo "cp /home/* /mnt/ FAIL"
rm -rf /home/* && echo "rm old home SUCCESS" || echo "rm old home FAIL"
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/
echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab && echo "update fstab SUCCESS" || echo "update fstab FAIL"
crontab -r
lsblk
#SUDO
