# !/bin/bash
fs=$(df -h |grep "zpool1/"|awk '{print $1}') 
for i in ${fs[@]}  
 do 
	echo "===========$i==========="|tee -a /home/vagrant/test_algo.log && /usr/bin/time -a -o /home/vagrant/test_algo.log  -f "���ଠ�� � �������:\n%C\n����㦥������ CPU: %P\n�६� �믮������: %e ᥪ"  cp -r /tmp/War_and_Peace.txt /$i |tee -a /home/vagrant/test_algo.log 
	sleep 5 && zfs get compressratio|grep "NAME\|$i " |tee -a /home/vagrant/test_algo.log 
	du -sh /"$i"/* |tee -a /home/vagrant/test_algo.log 
	/usr/bin/time -a -o /home/vagrant/test_algo.log  -f "���ଠ�� � �������:\n%C\n����㦥������ CPU: %P\n�६� �믮������: %e ᥪ" rm -rf /$i/War_and_Peace.txt|tee -a /home/vagrant/test_algo.log 
 done