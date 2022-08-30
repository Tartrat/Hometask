!!!''Домашнее задание по теме ZFS''

# Определить алгоритм с наилучшим сжатием.
# Определить настройки pool’a.
# Найти сообщение от преподавателей.
 Виртуалка поднимается из Vgrantfile с установленной zfs созданным зеркальным пулом `zpool1` из 2х дисков и всеми необходимыми файлами из задания

* ''Определяем алгоритм с наилучшим сжатием''

для начала создадим несколько датасетов для тестирования алгоритмов сжатия в формате test_{algo_name}


```
for i in gzip gzip-9 zle lzjb lz4 zstd; do zfs create zpool1/test_$i; zfs set compression=$i zpool1/test_$i && echo "create $i SUCCESS" || echo "create $i FAIL"; done
```
проверяем что на созданных датасетах включены алгоритмы сжатия


```
zfs get compression
NAME                PROPERTY     VALUE           SOURCE
zpool1              compression  off             default
zpool1/test_gzip    compression  gzip            local
zpool1/test_gzip-9  compression  gzip-9          local
zpool1/test_lz4     compression  lz4             local
zpool1/test_lzjb    compression  lzjb            local
zpool1/test_zle     compression  zle             local
zpool1/test_zstd    compression  zstd            local
```
далее проверяем эффективность сжатия каждого алгоритма


используется разархивированное ядро 

```
tar -xf /tmp/linux-5.19.4.tar.xz -C /tmp/
```
и текстовый файл `/tmp/War_and_Peace.txt`

используем последовательно 2 скрипта

`test_zfs_compression_bigdata.sh` и `test_zfs_compression_smallfile.sh`
из директории /vagrant

результаты сохраняются в лог файл `test_algo.log` 
на виртуалке лежит в `/home/vagrant/`

В результате проделанной работы самый эффективный алгоритм по сжатию gzip-9


```
===========zpool1/test_gzip-9===========
Информация о команде:
cp -r /tmp/War_and_Peace.txt /zpool1/test_gzip-9
Загруженность CPU: 100%
Время выполнения: 0.00 сек
NAME                PROPERTY       VALUE  SOURCE
zpool1/test_gzip-9  compressratio  2.67x  -
1.3M    /zpool1/test_gzip-9/War_and_Peace.txt
Информация о команде:
rm -rf /zpool1/test_gzip-9/War_and_Peace.txt
Загруженность CPU: 87%
Время выполнения: 0.00 сек

```

по сжатию и быстродействию zstd


```
===========zpool1/test_zstd===========
Информация о команде:
cp -r /tmp/War_and_Peace.txt /zpool1/test_zstd
Загруженность CPU: 50%
Время выполнения: 0.00 сек
NAME                PROPERTY       VALUE  SOURCE
zpool1/test_zstd    compressratio  2.59x  -
1.3M    /zpool1/test_zstd/War_and_Peace.txt
Информация о команде:
rm -rf /zpool1/test_zstd/War_and_Peace.txt
Загруженность CPU: 88%
Время выполнения: 0.00 сек
```
что особенно хорошо видно на разархивированном ядре
подробно можно изучить в логфайле `test_algo.log` 


* ''Определяем настройки pool’a.''

список команд для выполнения

```
tar -xf /tmp/zfs_task1.tar.gz  -C /tmp/
zpool import -d /tmp/zpoolexport/
zpool import -d /tmp/zpoolexport/ otus
zpool list
zpool status otus
zfs get recordsize otus
zfs get compression otus
zfs get checksum otus
zpool history
```
альтернативные команды

```
zfs get all|grep "otus "
zfs get all|grep "otus "|grep compression
zfs get all|grep "otus "|grep recordsize
zfs get all|grep "otus "|grep checksum
```
результаты выполнения можно посмотреть с помощью 


```
scriptreplay --timing=file.tm script.out
```
!!!!''ответы на вопросы из задания:''

*размер хранилища: 480M

*тип pool: mirror

*значение recordsize: 128K

*какое сжатие используется: zle

*какая контрольная сумма используется: sha256


* ''Находим сообщение от преподавателей.''

команды для выполнения

```
zfs receive otus/storage@task2 < /tmp/otus_task2.file
find /otus/ -name secret_message
cat /otus/storage/task1/file_mess/secret_message
```

результаты выполнения можно посмотреть с помощью 


```
scriptreplay --timing=file2.tm script2.out
```

Секретное сообщение: `https://github.com/sindresorhus/awesome`