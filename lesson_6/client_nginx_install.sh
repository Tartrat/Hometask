# !/bin/bash
# ver 1.0
# установка пакета из локального репо

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
							echo "is my repo enabled on system?"
							echo "$ts" "is my repo enabled on system?" >> "$logfile"
							echo "$ts" >> $logfile && yum repolist enabled |grep -o "My Test Repo" 2>&1 >> "$logfile"
							if [ $? -eq 0 ]
								then
									echo "my repo enabled on system"
									echo "$ts" "my repo enabled on system" >> "$logfile"
								else
									echo "can't find my repo in list of enabled repos. abort"
									echo "$ts" "can't find my repo in list of enabled repos. abort" >> "$logfile"
								exit 1
							fi
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

echo "check network avalability of repo and target packages"
echo "$ts" "check network avalability of repo" >> "$logfile"
echo "$ts" >> $logfile && curl http://10.0.0.50/repo/ 2>&1 >> "$logfile"
if [ $? -eq 0 ]
	then
		echo "repo is avalable"
		echo "$ts" "repo is avalable" >> "$logfile"
		echo "check for target packages"
		echo "$ts" "check for target packages" >> "$logfile"
		echo "$ts" >> $logfile && curl http://10.0.0.50/repo/|grep -i "nginx\|gd\|geoip" 2>&1 >> "$logfile"
		if [ $? -eq 0 ]
			then
				echo "target packages are avalable"
				echo "$ts" "target packages are avalable" >> "$logfile"
				echo "clean cache and prepare to install"
				echo "$ts" >> $logfile && yum clean all 2>&1 >> "$logfile"
				if [ $? -eq 0 ]
					then 
						echo "cache cleaned successfully"
						echo "$ts" "cache cleaned successfully" >> "$logfile"
						echo "check count of packages in repo"
						echo "$ts" "check count of packages in repo" >> "$logfile"
						count_packages=$(yum repoinfo MY_Test_Repo|grep Repo-pkgs|cut -d':' -f2|tr -d ' ')
						echo "packages in repo:"$count_packages""
						echo "$ts" "packages in repo:"$count_packages"" >> "$logfile"
						if [ "$count_packages" -ge 17 ]
							then 
								echo "install nginx"
								echo "$ts" >> $logfile && yum install -y --repo MY_Test_Repo nginx 2>&1 >> "$logfile"
								if [ $? -eq 0 ]
									then
										echo "nginx successfully installed"
										echo "$ts" "nginx successfully installed" >> "$logfile"
										echo "try to start it"
										echo "$ts" "try to start it" >> "$logfile"
										echo "$ts" >> $logfile && systemctl start nginx 2>&1 >> "$logfile"
										if [ $? -eq 0 ]
											then
												echo "nginx successfully started as systemd unit"
												echo "$ts" "nginx successfully started as systemd unit" >> "$logfile"
											else
												echo "can't start nginx service as systemd unit. abort"
												echo "$ts" "can't start nginx service as systemd unit. abort" >> "$logfile"
											exit 1
										fi
									else
										echo "can't install nginx. abort"
										echo "try view "$logfile" to debug"
										echo "$ts" "can't install nginx. abort" >> "$logfile"
										exit 1
								fi
							else
								echo "not enough packages in repo installation will not be successfull" 
								echo "$ts" "not enough packages in repo installation will not be successfull" >> "$logfile"
								echo "you can try to do it manually by "yum install -y --repo MY_Test_Repo nginx" command"
								exit 1						
						fi
					else
						echo "can't clear package manager cashe. abort"
						echo "try view "$logfile" to debug"
						echo "$ts" "can't clear package manager cashe. abort" >> "$logfile"
						exit 1
				fi
				
			else
				echo "target packages are absent in repo.abort"
				echo "try view "$logfile" to debug"
				echo "$ts" "target packages are a in repo.abort" >> "$logfile"
				exit 1
		fi
	else
		echo "can't connect to repo. abort"
		echo "try view "$logfile" to debug"
		echo "$ts" "can't connect to repo. abort" >> "$logfile"
		exit 1
fi


