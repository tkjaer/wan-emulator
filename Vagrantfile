ENV["VAGRANT_DEFAULT_PROVIDER"]="libvirt"
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Use generic ubuntu focal to get libvirt support
  config.vm.box = "generic/ubuntu2004"
  config.vm.synced_folder ".", "/vagrant"

  # Create the proxy server
  config.vm.define "proxy" do |proxy|
    proxy.vm.hostname="proxy"
    # Add private network for proxy<>client communication
    proxy.vm.network :private_network,
      :libvirt__network_name => 'inside_network',
      :libvirt__dhcp_enabled => false,
      # Assign a non-".1" address to stop vagrant from being noisy
      :ip => "192.0.2.2",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__forward_mode => 'veryisolated'
    proxy.vm.provider :libvirt do |v|
      v.driver = "kvm"
      v.memory = "2048"
      v.cpus=2
    end
    # Set up forwarding and SNAT
    proxy.vm.provision "shell", inline: <<-SHELL
      # sudo apt-get -qq update && sudo apt-get -qq upgrade
      DEBIAN_FRONTEND=noninteractive apt-get -qq install nftables
      echo 1 > /proc/sys/net/ipv4/ip_forward
      nft add table nat
      nft 'add chain nat postrouting { type nat hook postrouting priority 100 ; }'
      nft add rule nat postrouting ip saddr 192.0.2.0/24 oif eth0 snat to $(ip -4 addr show dev eth0|awk '/inet/ { print $2 }'|sed 's!\/.*!!')
      ethtool -K eth0 tso off
      ethtool -K eth1 tso off
    SHELL
  end

  # Create the client
  config.vm.define "client" do |client|
    client.vm.hostname="client"
    # Add private network for proxy<>client communication
    client.vm.network :private_network,
      :libvirt__network_name => 'inside_network',
      :libvirt__dhcp_enabled => false,
      :ip => "192.0.2.3",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__forward_mode => 'veryisolated'
    client.vm.provider :libvirt do |v|
      v.driver = "kvm"
      v.memory = "2048"
      v.cpus=2
    end
    # Change default route to go via proxy
    client.vm.provision "shell", inline: <<-SHELL
      # sudo apt-get -qq update && sudo apt-get -qq upgrade
      sudo $(ip route|awk '/default/ { printf "ip route del default via %s dev %s", $3, $5 }')
      sudo ip route add default via 192.0.2.2 dev eth1
    SHELL
  end

end
