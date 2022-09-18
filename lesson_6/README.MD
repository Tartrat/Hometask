## **Домашнее задание по теме  Управление пакетами. Дистрибьюция софта**

1. создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями).
1. создать свой репо и разместить там свой RPM.
1. реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо.
1. реализовать дополнительно пакет через docker.

Vagrantfile поднимает 2 виртуалки клиент и сервер на базе Centos 8 с  настроенным стендом для сборки пакетов
* установлены необходимые пакеты
* сделаны некоторые кастомизации OS

в репозитории и на виртуалках в дериктории /vagrant лежат необходимые файлы для сборки nginx из исходников
3 скрипта 
* `client_nginx_install.sh` - устанавливает nginx из своего репозитория запускать на клиенте после создания репо на сервере
* `nginx_install_from_source.sh` - позволяет установить\удалить nginx из исходного кода с помощью make
* `nginx_install_rmp_repo.sh` - создает локальный репозиторий собирает пакет nginx и размещает собранный пакет с зависимостями в локальном репо

Скрипты ведут подробный лог файл `nginx_install.log` расположенный в `/var/log/install_scripts/`

конф файлы
1. `local.repo` - кофигурационный файл для создания локального репо
1. `nginx.spec_good` - файл для сборки nginx с дополнительными модулями(geoip и.т.д)
1. `nginx_unitfile` - файл для запуска nginx в качестве службы при утсановке из исходного кода
1. `Vagrantfile` - файл для поднятия стенда

полный список опций с которыми собирается nginx

````
--prefix=/etc/nginx
--sbin-path=/usr/sbin/nginx
--modules-path=/usr/lib64/nginx/modules
--conf-path=/etc/nginx/nginx.conf
--error-log-path=/var/log/nginx/error.log
--http-log-path=/var/log/nginx/access.log
--pid-path=/var/run/nginx.pid
--lock-path=/var/run/nginx.lock
--http-client-body-temp-path=/var/cache/nginx/client_temp
--http-proxy-temp-path=/var/cache/nginx/proxy_temp
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp
--http-scgi-temp-path=/var/cache/nginx/scgi_temp
--user=nginx
--group=nginx
--with-compat
--with-file-aio
--with-threads
--with-http_addition_module
--with-http_auth_request_module
--with-http_dav_module
--with-http_flv_module
--with-http_gunzip_module
--with-http_gzip_static_module
--with-http_mp4_module
--with-http_random_index_module
--with-http_realip_module
--with-http_secure_link_module
--with-http_slice_module
--with-http_ssl_module
--with-http_stub_status_module
--with-http_sub_module
--with-http_v2_module
--with-mail
--with-mail_ssl_module
--with-stream
--with-stream_realip_module
--with-stream_ssl_module
--with-stream_ssl_preread_module
--with-http_geoip_module=dynamic
--with-http_image_filter_module=dynamic
--with-stream
--with-stream=dynamic
--with-cc-opt='-O2
-g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fexceptions -fstack-protector-strong -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie'
````
задание с docker пока не сделано
