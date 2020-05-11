#!/bin/bash

#создаём RAID5 из 5 дисков
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=5 /dev/sd[b-f]

#записываем конфигурацию в mdadm.conf
mkdir /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan >> /etc/mdadm/mdadm.conf

#создаём файловую систему поверх созданного raid. таблица разделов gpt, 5 равных разделов с файловой системой ext4
          parted -s /dev/md0 mklabel gpt
          parted /dev/md0 mkpart primary ext4 0% 20%
          parted /dev/md0 mkpart primary ext4 20% 40%
          parted /dev/md0 mkpart primary ext4 40% 60%
          parted /dev/md0 mkpart primary ext4 60% 80%
          parted /dev/md0 mkpart primary ext4 80% 100%
          for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
          
#создаём папку для монтирования разделов raid          
mkdir -p /mnt/raid/part{1,2,3,4,5}

#монтируем созданные разделы
for i in $(seq 1 5); do mount /dev/md0p$i /mnt/raid/part$i; done 

#обновляем fstab для автомонтирования созданных разделов raid после перезагрузки
for i in $(seq 1 5); do echo /dev/md0p$i /mnt/raid/part$i ext4  rw,user,exec 0 0 >> /etc/fstab; done


