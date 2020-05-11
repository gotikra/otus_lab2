# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otuslinux => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.101',
	:disks => {
		:sata1 => {
			:dfile => './otl1.vdi',
			:size => 250,
			:port => 1
		},
		:sata2 => {
            :dfile => './otl2.vdi',
            :size => 250, # Megabytes
			:port => 2
		},
        :sata3 => {
            :dfile => './otl3.vdi',
            :size => 250,
            :port => 3
                },
        :sata4 => {
            :dfile => './otl4.vdi',
            :size => 250, # Megabytes
            :port => 4
                },
        :sata5 => {
			:dfile => './otl5.vdi',
			:size => 250,
			:port => 5
		}

	}

		
  },
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

      config.vm.define boxname do |box|

          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s

          #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset

          box.vm.network "private_network", ip: boxconfig[:ip_addr]

          box.vm.provider :virtualbox do |vb|
            	  vb.customize ["modifyvm", :id, "--memory", "1024"]
                  needsController = false
		  boxconfig[:disks].each do |dname, dconf|
			  unless File.exist?(dconf[:dfile])
				vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                needsController =  true
                          end

		  end
                  if needsController == true
                     vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                     boxconfig[:disks].each do |dname, dconf|
                         vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                     end
                  end
          end
          
 	  box.vm.provision "shell", inline: <<-SHELL
	      mkdir -p ~root/.ssh
          cp ~vagrant/.ssh/auth* ~root/.ssh
	      yum install -y mdadm smartmontools hdparm gdisk
	      mdadm --create --verbose /dev/md0 --level=5 --raid-devices=4 /dev/sd[b-e] --spare-devices=1 /dev/sdf
	      mkdir /etc/mdadm
	      echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
          mdadm --detail --scan >> /etc/mdadm/mdadm.conf
          parted -s /dev/md0 mklabel gpt
          parted /dev/md0 mkpart primary xfs 0% 20%
          parted /dev/md0 mkpart primary xfs 20% 40%
          parted /dev/md0 mkpart primary xfs 40% 60%
          parted /dev/md0 mkpart primary xfs 60% 80%
          parted /dev/md0 mkpart primary xfs 80% 100%
          for i in $(seq 1 5); do sudo mkfs.xfs /dev/md0p$i; done
          mkdir -p /mnt/raid/part{1,2,3,4,5}
          for i in $(seq 1 5); do echo /dev/md0p$i /mnt/raid/part$i xfs  rw,user,exec 0 0 >> /etc/fstab; done
          for i in $(seq 1 5); do mount /dev/md0p$i /mnt/raid/part$i; done 
          
  	  SHELL

      end
  end
end

