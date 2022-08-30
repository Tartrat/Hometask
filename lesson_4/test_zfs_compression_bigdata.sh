# !/bin/bash
fs=$(df -h |grep "zpool1/"|awk '{print $1}') 
for i in ${fs[@]}  
 do 
	echo "===========$i==========="|tee -a /home/vagrant/test_algo.log && /usr/bin/time -a -o /home/vagrant/test_algo.log  -f "Информация о команде:\n%C\nЗагруженность CPU: %P\nВремя выполнения: %e сек"  cp -r  /tmp/linux-5.19.4 /$i |tee -a /home/vagrant/test_algo.log 
	zfs get compressratio|grep "NAME\|$i " |tee -a /home/vagrant/test_algo.log 
	df -h|grep "Filesystem\|$i "|tee -a /home/vagrant/test_algo.log 
	/usr/bin/time -a -o /home/vagrant/test_algo.log  -f "Информация о команде:\n%C\nЗагруженность CPU: %P\nВремя выполнения: %e сек" rm -rf /$i/linux-5.19.4|tee -a /home/vagrant/test_algo.log 
 done