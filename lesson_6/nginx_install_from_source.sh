# !/bin/bash
# ver 1.0
# установка\удаление nginx 1.23.1 из исходного кода

MY_PATH=$(dirname "$0")
MY_PATH=$( cd "$MY_PATH" && pwd )
echo "$MY_PATH" 
cd "$MY_PATH"
logfile="/var/log/install_scripts/nginx_install.log" # файл лога операций
logdir="/var/log/install_scripts" # директория с лог файлом
ts=$(date +"%d-%m-%Y %T") # timestamp для лога
source_dir=/tmp/nginx-1.23.1/ # директория с исходным кодом для компиляции

# Секция отвечает за работу с директорией логов
if [ -d "$logdir" ] # проверка существования директории для лог файла
	then
		echo "log dir exist"
		echo "check log file:"
		if [ -f "$logfile" ] # проверка существования лог файла
			then
				echo "log file exist"
			else 
				echo "log file is absent, create"
				sudo install -m 660 -g vagrant -o root  /dev/null "$logfile" # если файл отсутствует создаем
				
		fi
	else
		echo "log dir is absent, create"
		sudo install -m 755 -d "$logdir" -g vagrant -o root # если директория отсутствует создаем
		sudo install -m 660 -g vagrant -o root /dev/null "$logfile" # если файл отсутствует создаем
fi


install () # фунция установки nginx
{
nginx_proc_count=$(ps aux|grep -v grep|grep -c "nginx: master\|nginx: worker")
nginxd_active=$(systemctl is-active nginx.service) 
nginxd_enabled=$(systemctl is-enabled nginx.service)

echo "check for installed nginx"
echo "$ts" "check for installed nginx" >> "$logfile"
echo "$ts" >> "$logfile" && nginx -t 2>&1 >> "$logfile"
if [ $? -eq 0 ]
	then
		echo "nginx is allready installed"
		echo "$ts" "nginx is allready installed" >> "$logfile"
		echo "is nginx running?"
		if [ $nginx_proc_count -ge 1 ]
			then 
				echo "nginx is running"
				echo "$ts" "nginx is running" >> "$logfile"
			else
				echo "nginx is not running"
				echo "$ts" "nginx is not running" >> "$logfile"
		fi
		if [ $nginxd_active == active ]
			then 
				echo "nginx installed as systemd service to control it use systemctl options"
				echo "$ts" "nginx installed as systemd service" >> "$logfile"
			else 
				echo "nginx installed as non systemd service use to control it use nginx options"
				echo "$ts" "nginx installed as non systemd" >> "$logfile"
		fi
		exit 1
fi

echo "check nginx system user exists"
echo "$ts" "check nginx system user exists" >> "$logfile"
user_check=$( awk -F: '{ print $1}' /etc/passwd|grep nginx)
if [ -z "$user_check" ] # проверка что пользователь существует
	then 
		echo "user is absent, create"
		echo "$ts" "user is absent, create" >> "$logfile"
		adduser  --no-create-home  --system  --user-group --shell /bin/false nginx 2>&1 >> "$logfile" # добавляем пользователя от имени которого буде запускаться nginx
		if [ $? -eq 0 ]
			then
				echo "user successfully added"
				echo "$ts" "user successfully added" >> "$logfile"
			else
				echo "can't add user. try to do it manually. exit"
				echo "$ts" "can't add user exit" >> "$logfile"
				exit 1
		fi
	else 
		echo "user exsists skip"
		echo "$ts" "user exists skip" >> "$logfile"
fi



cd "$source_dir"
if [ $? -eq 0 ]
	then 
		echo "source directory is "$source_dir""
		echo "$ts" "source directory is "$source_dir"" >> "$logfile"
	else
		echo "source directory "$source_dir" is absent"
		echo "$ts" "source directory "$source_dir" is absent" >> "$logfile"
		echo "download and extract"
		echo "$ts" "download and extract" >> "$logfile"
		wget -O /tmp/nginx-1.23.1.tar.gz https://nginx.org/download/nginx-1.23.1.tar.gz 2>&1 |tee -a "$logfile"
		tar -xf /tmp/nginx-1.23.1.tar.gz -C /tmp/ 2>&1 |tee -a "$logfile"
		cd "$source_dir"
fi

# 
echo "start build processes"
echo "$ts" "start build processes" >> "$logfile"
echo "create makefile"
echo "$ts" "create makefile" >> "$logfile"
echo "$ts" >> "$logfile" && ./configure	--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-http_geoip_module=dynamic --with-http_image_filter_module=dynamic --with-stream --with-stream=dynamic --with-cc-opt='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fexceptions -fstack-protector-strong -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie' 2>&1|tee -a "$logfile"

echo "start make && make install processes"
echo "$ts" "start make && make install processes" >> "$logfile"
echo "$ts" >> "$logfile" && make 2>&1|tee -a "$logfile"  && make install 2>&1 |tee -a "$logfile"

echo "create nginx cache directory"
echo "$ts" "create nginx cache directory" >> "$logfile"
echo "$ts" >> "$logfile" && mkdir /var/cache/nginx 2>&1 >> "$logfile" && echo "create /var/cache/nginx SUCCESS"|tee -a "$logfile" || echo "create /var/cache/nginx  FAIL"|tee -a "$logfile"

echo "change owner and permissions for nginx cache directory"
echo "$ts" "change owner and permissions for nginx cache directory" >> "$logfile"
echo "$ts" >> "$logfile" && chmod -R 700 /var/cache/nginx/ 2>&1 >> "$logfile" && echo "permissions change SUCCESS"|tee -a "$logfile"||echo "permissions change FAIL"|tee -a "$logfile"
echo "$ts" >> "$logfile" && chown -R nginx:nginx /var/cache/nginx/ 2>&1 >> "$logfile" && echo "owner change SUCCESS"||echo "owner change FAIL"|tee -a "$logfile"

echo "test nginx run"
echo "$ts" "test nginx run" >> "$logfile"
echo "$ts" >> "$logfile" && nginx 2>&1 >> "$logfile"
if [ $? -eq 0 ]
	then 
		echo "nginx test run is SUCCESS continue"
		echo "$ts" "nginx test run is SUCCESS continue" >> "$logfile"
	else
		echo "nginx test run is FAIL abort"
		echo "try view "$logfile" to debug"
		echo "$ts" "nginx test run is FAIL abort" >> "$logfile"
		exit 1
fi


echo "prepare to run nginx as systemd unit"
echo "$ts" "prepare to run nginx as systemd unit" >> "$logfile"
nginx_proc_count=$(ps aux|grep -v grep|grep -c "nginx: master\|nginx: worker")
if [ $nginx_proc_count -ge 1 ]
	then 
		echo "nginx successfully installed make unitfile for autostart" 
		echo "$ts" "nginx successfully installed make unitfile for autostart" >> "$logfile"
		echo "$ts" >> "$logfile" && nginx -s stop 2>&1 >> "$logfile" 
		if [ $? -eq 0 ]
			then 
				echo "nginx test stop SUCCESS"
				echo "$ts" "nginx test stop SUCCESS" >> "$logfile"
			else
				echo "nginx test stop FAIL try to kill them"
				echo "$ts" "nginx test stop FAIL try to kill them" >> "$logfile"
				echo "$ts" >> "$logfile" && pkill -9 nginx 2>&1 >> "$logfile"
					if [ $? -eq 0 ]
						then 
							echo "nginx proc is successfully killed"
							echo "$ts" "nginx proc is successfully killed" >> "$logfile"
						else
							echo "cant kill the nginx proc, abort"
							echo "try view "$logfile" to debug"
							echo "$ts" "can't kill the nginx proc, abort" >> "$logfile"
							exit 1
					fi
		fi
		echo "is unitfile exists?"
		echo "$ts" "is unitfile exists?" >> "$logfile"
		unitfile=/vagrant/nginx_unitfile
		if [ -f "$unitfile" ] # проверка существования unit файла nginx
			then
				echo "$unitfile" "exists"
				echo "$ts" "$unitfile" "exists" >> "$logfile"
				echo "check format"
				echo "$ts" "check format" >> "$logfile"
				if [ -s "$unitfile" ] # проверка что файл не пустой
					then  
					grep "Unit" "$unitfile" > /dev/null && grep "Service"  "$unitfile" > /dev/null && grep "Install"  "$unitfile" > /dev/null
						if [ $? -eq 0 ] # проверка формата существующего файла
						then 
							echo "unit file "$unitfile" format is OK"
							echo "$ts" "unit file "$unitfile" format is OK" >> "$logfile"
							echo "$ts" >> "$logfile" && cp "$unitfile" /etc/systemd/system/nginx.service 2>&1 >> "$logfile"
								if [ $? -eq 0 ] # проверка формата существующего файла
									then 
										echo "unit file successfully copied"
										echo "$ts" "unit file successfully copied" >> "$logfile"
									else
										echo "can't copy unit file"
										echo "try view "$logfile" to debug"
										echo "$ts" "can't copy unit file" >> "$logfile"
									fi
						else
							echo "unit file "$unitfile" bad format abort"
							echo "$ts" "unit file "$unitfile" bad format abort" >> "$logfile"
							exit 1
						fi
					else
						echo "$unitfile" "is empty"
						echo "$ts" "$unitfile" "is empty" >> "$logfile"
						exit 1
				fi
			else
			echo "$unitfile" "is absent"
			echo "$ts" "$unitfile" "is absent" >> "$logfile"
			exit 1
		fi
		
		echo "make nginx autostartable on boot"
		echo "$ts" "make nginx autostartable on boot" >> "$logfile"
		echo "$ts" >> "$logfile" && systemctl enable nginx.service  2>&1 >> "$logfile"
		if [ $? -eq 0 ]
			then 
				echo "nginx service enabled"
				echo "$ts" "nginx service enabled" >> "$logfile"
			else 
				echo "failed to enable nginx service"
				echo "nginx will not start automatically on next boot" 
				echo "try view "$logfile" to debug"
				echo "$ts" "failed to enable nginx service" >> "$logfile"
		fi	
		echo "start nginx as systemd unit"
		echo "$ts" "start nginx as systemd unit" >> "$logfile"
		echo "$ts" >> "$logfile" && systemctl start nginx.service 2>&1 >> "$logfile"
		if [ $? -eq 0 ]
			then 
				echo "nginx service successfully installed"
				echo "$ts" "nginx service successfully installed" >> "$logfile"
			else
				echo "failed to run nginx service as systemd unit"
				echo "nginx will not start automatically on next boot"
				echo "try view "$logfile" to debug"
				echo "$ts" "failed to enable nginx service" >> "$logfile"
				exit 1
		fi
	else
		echo "failed install nginx service"
		echo "try view "$logfile" to debug"
		exit 1
fi

}


uninstall ()
{
nginx_proc_count=$(ps aux|grep -v grep|grep -c "nginx: master\|nginx: worker")
nginxd_active=$(systemctl is-active nginx.service) 
nginxd_enabled=$(systemctl is-enabled nginx.service)

echo "prepare to remove nginx service"
echo "$ts" "prepare to remove nginx service" >> "$logfile"

echo "is nginx active?"
echo "$ts" "is nginx active?" >> "$logfile"
nginxd_active=$(systemctl is-active nginx.service)
if [ $nginxd_active == active ]
	then 
		echo "nginx is active"
		echo "$ts" "nginx is active" >> "$logfile"
		echo "try to stop nginx.service"
		echo "$ts" "try to stop nginx.service" >> "$logfile"
		echo "$ts" >> "$logfile" && systemctl stop nginx.service 2>&1 >> "$logfile"
		if [ $? -eq 0 ]
			then 
				echo "nginx.service successfully stoped"
				echo "$ts" "nginx.service successfully stoped" >> "$logfile"
				echo "try to find nginx proc"
			else
				echo "failed to stop nginx.service"
				echo "try view "$logfile" to debug"
				echo "$ts" "failed to stop nginx.service" >> "$logfile"
				exit 1
		fi
		else
			echo "nginx.service is not active"
			echo "try to find nginx proc"
fi

echo "are any nginx processes present?"
echo "$ts" "are any nginx processes present?" >> "$logfile"
nginx_proc_count=$(ps aux|grep -v grep|grep -c "nginx: master\|nginx: worker")
if [ $nginx_proc_count -ge 1 ]
	then 
		echo "found nginx proc try to stop them"
		echo "$ts" "found nginx proc try to stop them" >> "$logfile"
		echo "$ts" >> "$logfile" && nginx -s stop 2>&1 >> "$logfile"
		if [ $? -eq 0 ]
			then 
				echo "nginx stop SUCCESS"
				echo "$ts" "nginx stop SUCCESS" >> "$logfile"
			else
				echo "nginx stop FAIL abort"
				echo "try view "$logfile" to debug"
				echo "$ts" "nginx test stop FAIL abort" >> "$logfile"
				echo "try to kill the nginx proc"
				echo "$ts" >> "$logfile" && pkill -9 nginx 2>&1 >> "$logfile"
				if [ $? -eq 0 ]
					then 
						echo "nginx proc is successfully killed"
						echo "$ts" "nginx proc is successfully killed" >> "$logfile"
					else
						echo "cant kill the nginx proc, abort"
						echo "try view "$logfile" to debug"
						echo "$ts" "can't kill the nginx proc, abort" >> "$logfile"
						exit 1
				fi
		fi
	else
		echo "there are no any nginx proc, continue"
		echo "$ts" "there are no any nginx proc, continue" >> "$logfile"	
fi

echo "check nginx service is autostartable on boot"
echo "$ts" "check nginx service is autostartable on boot" >> "$logfile"
nginxd_enabled=$(systemctl is-enabled nginx.service)
if [ $nginxd_enabled == enabled ]
	then
		echo "nginx service is enabled"
		echo "$ts" "nginx service is enabled" >> "$logfile"
		echo "try to disable nginx.service"
		echo "$ts" "try to disable nginx.service" >> "$logfile"
		echo "$ts" >> "$logfile" && systemctl disable nginx.service 2>&1 >> "$logfile"
		if [ $? -eq 0 ]
			then 
				echo "nginx.service successfully disabled"
				echo "$ts" "nginx.service successfully disabled" >> "$logfile"
			else
				echo "failed to disable nginx.service"
				echo "try view "$logfile" to debug"
				echo "$ts" "failed to disable nginx.service" >> "$logfile"
				exit 1
		fi
	else
		echo "nginx.service is disabled. nothing to do"
		echo "$ts" "nginx.service is disabled. nothing to do" >> "$logfile"
fi	

echo "delete nginx files"
echo "$ts" "delete nginx files" >> "$logfile"
echo "$ts" >> "$logfile" && rm -rf /etc/systemd/system/nginx.service /etc/nginx /var/log/nginx /usr/sbin/nginx /var/www/* /usr/lib64/nginx/ /var/cache/nginx /usr/sbin/nginx.old /usr/share/nginx /usr/share/man/man8/nginx.8.gz /usr/lib/systemd/system/nginx.service 2>&1 >> "$logfile"
if [ $? -eq 0 ]
	then 
		echo "files successfully deleted"
		echo "$ts" "files successfully deleted" >> "$logfile"
	else 
		echo "can't delete files. abort"
		echo "try view "$logfile" to debug"
		echo "$ts" "can't delete files. abort" >> "$logfile"
		exit 1
fi

echo "delete nginx user"
echo "$ts" "delete nginx user" >> "$logfile"
user_check=$( awk -F: '{ print $1}' /etc/passwd|grep nginx)
if [ -z "$user_check" ]
	then 
		echo "user is absent, nothing to do"
		echo "$ts" "user is absent, nothing to do" >> "$logfile"
	else 
		echo "user exsists remove"
		echo "$ts" "user exsists remove" >> "$logfile"
		userdel -r nginx
fi

echo "nginx was successfully removed"
echo "$ts" "nginx was successfully removed" >> "$logfile"
}

clear_log ()
{
if [ -f "$logfile" ]
	then 
		echo "try to delete logs"
		echo "$ts" "try to delete logs" >> "$logfile"
		echo "$ts" >> "$logfile" && rm -rf "$logfile" "$logdir" 2>&1 >> "$logfile"
		if [ $? -eq 0 ]
			then 
				echo "logs successfully deleted"
			else
				echo "can't delete logs"
				echo "try view "$logfile" to debug"
		fi
fi
}

# секция отвечает за  выбор опреации установка удаление или очистка логов
echo "variables:"
PS3="choose install uninstall nginx service or clear logs of this script:"
select type in install uninstall clear_log   # выбираем что будем делать
do
	case "$type" in 
		install)	echo "you choose install nginx option"
					install
					break
					;;
		uninstall)	echo "you choose uninstall nginx option"
					read -sn1 -p "Press any key to continue or ctrl+c to abort"; echo
					uninstall
					break
					;;
		clear_log) echo "you choose clear log option"
					clear_log
					break
					;;
		*)	echo "invalid option, you must choose install uninstall or clear_log to continue, try again"
			;;
	esac
done