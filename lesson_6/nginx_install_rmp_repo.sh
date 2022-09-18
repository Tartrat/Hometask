# !/bin/bash
# ver 1.0
# сборка пакета nginx 1.23.1 из исходного кода и создание локального репо

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


make_rpm_package ()
{
echo "start processes of rpm build"
echo "$ts" "start processes of rpm build" >> $logfile
echo "$ts" >> $logfile &&  rpmdev-setuptree 2>&1 >> "$logfile"
if [ $? -eq 0 ]
	then
		echo "successfully create build dir"
		echo "$ts" "successfully create build dir" >> "$logfile"
	else
		echo "can't create build dir"
		echo "$ts" "can't create build dir" >> "$logfile"
		exit 1
fi

echo "check source package is present"
echo "$ts" "check source package is present" >> $logfile
source_package=/tmp/nginx-1.23.1-1.el8.ngx.src.rpm
if [ -f "$source_package" ]
	then 
		echo "source package is "$source_package""
		echo "$ts" "source package is "$source_package"" >> "$logfile"
	else
		echo "source package  "$source_package" is absent"
		echo "$ts" "source package  "$source_package" is absent" >> "$logfile"
		echo "download it"
		echo "$ts" echo "download it" >> "$logfile"
		wget -O /tmp/nginx-1.23.1-1.el8.ngx.x86_64.rpm https://nginx.org/packages/mainline/centos/8/x86_64/RPMS/nginx-1.23.1-1.el8.ngx.x86_64.rpm |tee -a "$logfile"
fi

echo "extracting source package"
echo "$ts" "installing source package" >> $logfile
echo "$ts" >> $logfile &&  rpm -Uvh /tmp/nginx-1.23.1-1.el8.ngx.src.rpm 2>&1 >> "$logfile"
if [ $? -eq 0 ]
	then
		echo "package successfully extracted"
		echo "$ts" "package successfully extracted" >> "$logfile"
	else
		echo "can't extract package. abort"
		echo "try view "$logfile" to debug"
		echo "$ts" "can't extract package.abort" >> "$logfile"
		exit 1
fi

echo "check spec file is present"
echo "$ts" "check spec file is present" >> $logfile
spec_file=/vagrant/nginx.spec_good
if [ -f "$spec_file" ]
	then 
		echo "spec file is "$spec_file" try to copy it to build dir"
		echo "$ts" "spec file is "$spec_file" try to copy it to build dir" >> "$logfile"
		echo "$ts" >> $logfile &&  cp "$spec_file" /home/builder/rpmbuild/SPECS/nginx.spec 2>&1 >> "$logfile"
		if [ $? -eq 0 ]
				then
					echo ""$spec_file" successfully copied to build dir"
					echo "$ts" ""$spec_file" successfully copied to build dir" >> "$logfile"
				else
					echo "can't copy "$spec_file" to build dir. abort"
					echo "try view "$logfile" to debug"
					echo "$ts" "can't copy "$spec_file" to build dir. abort" >> "$logfile"
					exit 1
		fi
	else
		echo "spec file "$spec_file" is absent. abort"
		echo "$ts" "spec file "$spec_file" is absent. abort" >> "$logfile"
fi


cd /home/builder/rpmbuild/SPECS/
echo "start build processes"
echo "$ts" "start build processes"  >> $logfile
echo "$ts" >> $logfile &&  rpmbuild -bb nginx.spec 2>&1 |tee -a "$logfile"
builded_package=/home/builder/rpmbuild/RPMS/x86_64/nginx-1.23.1-1.el8.ngx.x86_64.rpm
if [ -f "$builded_package" ]
	then 
		echo ""$builded_package" is exist. Success"
		echo "$ts" ""$builded_package" is exist. Success" >> "$logfile"
		exit 0
	else
		echo ""$builded_package" is absent. abort"
		echo "try view "$logfile" to debug"
		echo "$ts" ""$builded_package" is absent. abort" >> "$logfile"
		exit 1
		exit 1
fi
}


make_repo ()
{
echo "download dependenses for main package in  My Repo"
echo "$ts" "download dependenses for main package in  My Repo"  >> $logfile
echo "$ts" >> $logfile && yumdownloader -x '*i686'  --resolve --destdir=/tmp/pac/ GeoIP GeoIP-GeoLite-data dejavu-fonts-common dejavu-sans-fonts fontconfig fontpackages-filesystem gd jbigkit-libs libX11 libX11-common libXau libXpm libjpeg-turbo libtiff libwebp libxcb 2>&1 >> "$logfile"
if [ $? -eq 0 ]
		then
			echo "dependenses successfully downloaded"
			echo "$ts" "dependenses successfully downloaded" >> "$logfile"
		else
			echo "can't download dependenses. abort"
			echo "try view "$logfile" to debug"
			echo "$ts" "can't download dependenses. abort" >> "$logfile"
			exit 1
fi

echo "make dir for My Repo"
echo "$ts" "make dir for My Repo"  >> $logfile
My_Repo_dir=/usr/share/nginx/html/repo
echo "$ts" >> $logfile && mkdir "$My_Repo_dir"  2>&1 >> "$logfile"
if [ $? -eq 0 ]
		then
			echo ""$My_Repo_dir" successfully created"
			echo "$ts" ""$My_Repo_dir" successfully created" >> "$logfile"
		else
			echo "can't create "$My_Repo_dir" . abort"
			echo "try view "$logfile" to debug"
			echo "$ts" "can't create "$My_Repo_dir" . abort" >> "$logfile"
			exit 1
fi

echo "copy main package to My Repo"
echo "$ts" "make dir for My Repo"  >> $logfile
echo "$ts" >> $logfile && cp /home/builder/rpmbuild/RPMS/x86_64/nginx-*.rpm "$My_Repo_dir" 2>&1 >> "$logfile"
if [ $? -eq 0 ]
		then
			echo "main package successfully copied"
			echo "$ts" "main package successfully copied" >> "$logfile"
		else
			echo "can't copy main package. abort"
			echo "try view "$logfile" to debug"
			echo "$ts" "can't copy main package. abort" >> "$logfile"
			exit 1
fi

echo "copy dependenses packages to My Repo"
echo "$ts" "copy dependenses packages to My Repo"  >> $logfile
echo "$ts" >> $logfile && cp /tmp/pac/*.rpm "$My_Repo_dir" 2>&1 >> "$logfile"
if [ $? -eq 0 ]
		then
			echo "dependenses packages successfully copied"
			echo "$ts" "dependenses packages successfully copied" >> "$logfile"
		else
			echo "can't copy dependenses packages. abort"
			echo "try view "$logfile" to debug"
			echo "$ts" "can't copy dependenses packages. abort" >> "$logfile"
			exit 1
fi

echo "make My Repo conf file"
echo "$ts" "make My Repo conf file"  >> $logfile
repo_conf_file=/vagrant/local.repo
if [ -f "$repo_conf_file" ]
	then 
		echo "repo conf  file is "$repo_conf_file" try to copy it to conf dir"
		echo "$ts" "repo conf  file is "$repo_conf_file" try to copy it to conf dir" >> "$logfile"
		echo "$ts" >> $logfile &&  cp "$repo_conf_file" /etc/yum.repos.d/local.repo 2>&1 >> "$logfile"
		if [ $? -eq 0 ]
				then
					echo ""$repo_conf_file" successfully copied to conf dir"
					echo "$ts" ""$repo_conf_file" successfully copied to conf dir" >> "$logfile"
					echo "set owner and permissions"
					echo "$ts" >> $logfile &&  chown root:root /etc/yum.repos.d/local.repo 2>&1 >> "$logfile"
					if [ $? -eq 0 ]
						then
							echo "owner successfully changed"
							echo "$ts" "owner successfully changed" >> "$logfile"
						else
							echo "failed to change owner. abort"
							echo "$ts" "failed to change owner. abort" >> "$logfile"
							exit 1
					fi
					echo "$ts" >> $logfile && chmod 644 /etc/yum.repos.d/local.repo 2>&1 >> "$logfile"
					if [ $? -eq 0 ]
						then
							echo "set permissions successfully"
							echo "$ts" "set permissions successfully" >> "$logfile"
						else
							echo "failed to set permissions.abort"
							echo "$ts" "failed to set permissions.abort" >> "$logfile"
							exit 1
					fi
				else
					echo "can't copy "$repo_conf_file" to build dir. abort"
					echo "try view "$logfile" to debug"
					echo "$ts" "can't copy "$repo_conf_file" to build dir. abort" >> "$logfile"
					exit 1
		fi
	else
		echo "repo conf  file  "$repo_conf_file" is absent. abort"
		echo "$ts" "repo conf  file  "$repo_conf_file" is absent. abort" >> "$logfile"
fi
echo "create MY Repo"
echo "$ts" "create MY Repo" >> "$logfile"
echo "$ts" >> $logfile && createrepo /usr/share/nginx/html/repo 2>&1 >> "$logfile"
if [ $? -eq 0 ]
		then
			echo "My Repo was successfully created"
			echo "$ts" "My Repo was successfully created" >> "$logfile"
		else
			echo "can't create My Repo. abort"
			echo "try view "$logfile" to debug"
			echo "$ts" "can't create My Repo. abort" >> "$logfile"
			exit 1
fi
}



echo "Starting processes to create My Repo"
echo "$ts" "Starting processes to create My Repo" >> "$logfile"
user_check=$( awk -F: '{ print $1}' /etc/passwd|grep builder)
echo "check system for user for builds"
echo "$ts" "check system for user for builds" >> "$logfile"
if [ -z "$user_check" ] # проверка что пользователь существует
	then 
		echo "user is absent, create"
		echo "$ts" "user is absent, create" >> "$logfile"
		useradd -g vagrant -m builder 2>&1 >> "$logfile" # добавляем пользователя для сборок
		if [ $? -eq 0 ]
			then
				echo "user for builds successfully created"
				echo "$ts" "user for builds successfully created" >> "$logfile"
			else
				echo "can't create user for build's try to do it manually. exit"
				echo "$ts" "can't create user for build's exit" >> "$logfile"
				exit 1
		fi
	else 
		echo "user exsists skip"
		echo "$ts" "user exists skip" >> "$logfile"
fi

echo "run build processes by builduser"
echo "$ts" "run build processes by builduser" >> "$logfile"
echo "$ts" >> $logfile && sudo -H -u builder  whoami 2>&1 >> "$logfile"
	if [ $? -eq 0 ]
		then
			echo "successfully switched to builduser"
			echo "$ts" "successfully switched to builduser" >> "$logfile"
			echo "$ts" "user for build's": $whoami  2>&1 >> "$logfile"
			export -f make_rpm_package
			export logfile="/var/log/install_scripts/nginx_install.log"
			su builder -c "make_rpm_package"
		else
			echo "can't switch to user for build's. abort"
			echo "$ts" "can't switch to user for build's. abort" >> "$logfile"
			exit 1
	fi

current_user=$(whoami)
if [ "$current_user" == root ]
	then 
		echo "installing nginx from own packge"
		echo "$ts" "installing nginx from own packge" >> "$logfile"
		echo "$ts" >> $logfile &&  rpm -i /home/builder/rpmbuild/RPMS/x86_64/nginx-1.23.1-1.el8.ngx.x86_64.rpm 2>&1 >> "$logfile"
			if [ $? -eq 0 ]
				then
					echo "nginx is successfully installed"
					echo "$ts""nginx is successfully installed" >> "$logfile"
					echo "try to start it"
					echo "$ts" >> $logfile &&  systemctl start nginx.service 2>&1 >> "$logfile"
					if [ $? -eq 0 ]
						then
							echo "nginx servise was successfully started"
							echo "$ts" "nginx servise was successfully started" >> "$logfile"
							echo "$ts" >> $logfile && systemctl enable nginx.service 2>&1 >> "$logfile"
							if [ $? -eq 0 ]
								then
									echo "nginx servise was successfully enabled"
									echo "$ts" "nginx servise was successfully enabled" >> "$logfile"
								else
									echo "can't enable nginx service. abort"
									echo "try view "$logfile" to debug"
									echo "$ts" "can't enable nginx service. abort" >> "$logfile"
									exit 1
							fi
							echo "modify default nginx conf to be able add packages"
							echo "$ts" "modify default nginx conf to be able add packages" >> "$logfile"
							string=$(grep -n "index  index.html index.htm;" /etc/nginx/conf.d/default.conf|sed -r 's/:.+//')
							echo "$ts" >> $logfile && sed -i "${string}a\        autoindex on;" /etc/nginx/conf.d/default.conf 2>&1 >> "$logfile"
							if [ $? -eq 0 ]
								then
									echo "nginx conf was successfully modified"
									echo "$ts" "nginx conf was successfully modified" >> "$logfile"
									echo "$ts" >> $logfile && nginx -t 2>&1 >> "$logfile"
									if [ $? -eq 0 ]
										then
											echo "nginx conf was successfully checked"
											echo "$ts" "nginx conf was successfully checked" >> "$logfile"
											echo "$ts" >> $logfile && systemctl reload nginx 2>&1 >> "$logfile"
											if [ $? -eq 0 ]
												then
													echo "nginx conf was successfully reload"
													echo "$ts" "nginx conf was successfully reload" >> "$logfile"
													make_repo
												else
													echo "an error occured while nginx reload. abort"
													echo "try view "$logfile" to debug"
													echo "$ts" "an error occured while nginx reload. abort" >> "$logfile"
													exit 1
											fi
										else
											echo "an error occured while checking nginx conf. abort"
											echo "try view "$logfile" to debug"
											echo "$ts" "an error occured while checking nginx conf. abort" >> "$logfile"
											exit 1
									fi
								else
									echo "can't modify nginx conf. abort"
									echo "try view "$logfile" to debug"
									echo "$ts" "can't modify nginx conf. abort" >> "$logfile"
									exit 1
							fi
						else
							echo "can't start nginx service. abort"
							echo "try view "$logfile" to debug"
							echo "$ts" "can't start nginx service. abort" >> "$logfile"
							exit 1
					fi
				else
					echo "can't install nginx service. abort"
					echo "try view "$logfile" to debug"
					echo "$ts" "can't install nginx service. abort" >> "$logfile"
					exit 1
			fi
	else
		echo "run this script as root"
		echo "try view "$logfile" to debug"
		echo "$ts" "$current_user" >> "$logfile"
		exit 1
fi
