# ДЗ2.Работа с mdadm
1.в Vagrantfile добавлен 5 диск  
*:sata5 => {*  
*:dfile => './ot5.vdi',*  
*:size => 250,*  
*:port => 5*  
*}*

2. в опцию Vagrantfile box.vm.provision добавлены комманды для автосборки RAID5:

2.1. создаём RAID5 из 5 дисков:
>*mdadm --create --verbose /dev/md0 --level=5 --raid-devices=4 /dev/sd[b-e] --spare-devices=1 /dev/sdf*  

2.2. записываем конфигурацию в mdadm.conf

*mkdir /etc/mdadm*
*echo "DEVICE partitions" > /etc/mdadm/mdadm.conf*
*mdadm --detail --scan >> /etc/mdadm/mdadm.conf*

2.3. создаём файловую систему поверх созданного raid. таблица разделов gpt, 5 равных разделов с файловой системой xfs

*parted -s /dev/md0 mklabel gpt*  
*parted /dev/md0 mkpart primary xfs 0% 20%*  
*parted /dev/md0 mkpart primary xfs 20% 40%*  
*parted /dev/md0 mkpart primary xfs 40% 60%*  
*parted /dev/md0 mkpart primary xfs 60% 80%*  
*parted /dev/md0 mkpart primary xfs 80% 100%*  
*for i in $(seq 1 5); do sudo mkfs.xfs /dev/md0p$i; done*  
2.4. создаём папки для монтирования разделов raid:

*mkdir -p /mnt/raid/part{1,2,3,4,5}*

2.5. монтируем созданные разделы

*for i in $(seq 1 5); do mount /dev/md0p$i /mnt/raid/part$i; done*

2.6. обновляем fstab для автомонтирования созданных разделов raid после перезагрузки

*for i in $(seq 1 5); do echo /dev/md0p$i /mnt/raid/part$i ext4  rw,user,exec 0 0 >> /etc/fstab; done*

3.Подготовлен bash-скрипт mdadm.sh, который можно запустить на поднятом образе, и создающий RAID5 из 4 дисков  +1 spare

4.Содержимое файла /etc/mdadm/mdadm.conf:

*DEVICE partitions*
*ARRAY /dev/md0 metadata=1.2 spares=2 name=otuslinux:0* *UUID=63b046e6:b1c4b421:f7a4fc28:1f004106*

5.вывод комманды *mdadm -D /dev/md0* после перезагрузки паоднятой виртуальной машины:

>/dev/md0:  
>Version : 1.2  
>Creation Time : Mon May 11 08:50:49 2020  
>Raid Level : raid5  
>Array Size : 761856 (744.00 MiB 780.14 MB)  
>Used Dev Size : 253952 (248.00 MiB 260.05 MB)  
>Raid Devices : 4  
>Total Devices : 5  
>Persistence : Superblock is persistent  
>  
>Update Time : Mon May 11 08:53:50 2020  
>State : clean  
>Active Devices : 4  
>Working Devices : 5  
>Failed Devices : 0  
>Spare Devices : 1  
>
>Layout : left-symmetric  
>Chunk Size : 512K  
>  
>Consistency Policy : resync  
>  
>Name : otuslinux:0  (local to host otuslinux)  
>UUID : 63b046e6:b1c4b421:f7a4fc28:1f004106  
>Events : 23  
>   
>Number   Major   Minor   RaidDevice State  
>0       8       16        0      active sync   /dev/sdb  
>1       8       32        1      active sync   /dev/sdc 
>2       8       48        2      active sync   /dev/sdd  
>5       8       64        3      active sync   /dev/sde  
> 
>4       8       80        -      spare   /dev/sdf  
>
