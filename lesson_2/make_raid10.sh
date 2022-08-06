# /bin/bash
# ver 0.1
# требуются права root
# подразумевается что в ситеме установлены mdadm и sgdisk

# создаем raid10 
mdadm --create /dev/md0 --level=10 --raid-devices=4 /dev/sd[b-e]
# работа с созданным raid
DEVICE=/dev/md0
	for i in $(seq 1 5)  
		do 
			sgdisk -n $i:0:+20M $DEVICE # создаем 5 партиций
			mkfs.ext4 /dev/md0p$i # форматируем созданные партиции в ext4
			mkdir /mnt/test$i # создаем точки монтирования
			# добавляем точки монтирования в fstab
			mountpoint=$(grep -o /mnt/test$i  /etc/fstab)
			grep /mnt/test$i /etc/fstab > /dev/null 2>&1
			if [ "$?" -eq 0 ]
					then
							echo $mountpoint "allready exist in fstab"
					else
							echo "add new mountpoint" "$mountpoint" "to fstab"
							echo "/dev/md0p"$i" /mnt/test"$i"/ ext4 defaults 1 2" >> /etc/fstab
			fi
		done
# выводим инфу о созданном raid
mdadm --detail /dev/md0
# формируем .conf файл для сборки raid при загрузке
mdadm --verbose --detail --scan > /etc/mdadm.conf
# монтируем все что добавилось в fstab
mount -a