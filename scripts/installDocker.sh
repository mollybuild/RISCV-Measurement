#! /bin/bash

# Use this script to install docker on D1/openEuler.
# Due to wget issue and git clone issue, you should put prebuilt go and docker packages and CNI plugins and this script in the same folder by yourself. As follow:
# 1.go1.17.linux-riscv64.tar.gz
# 2.docker-19.03.8-dev_riscv64.tar.gz
# 3.https://github.com/containernetworking/plugins.git
# 4.this script.

# Use 'source installDocker.sh' to run this script. Do not use './installDocker.sh'.

# 1. install prerequisistes
yum update
yum install -y iptables-services
yum install -y yajl-devel

# 2. download go and docker prebuilt packages

if [ ! -f go*tar* ]; then
	wget https://github.com/carlosedp/riscv-bringup/releases/download/v1.0/go1.17.linux-riscv64.tar.gz
fi

if [ ! -f docker*tar* ]; then
	wget https://github.com/carlosedp/riscv-bringup/releases/download/v1.0/docker-19.03.8-dev_riscv64.tar.gz
fi

# 3. install go
tar zxf go1.17.linux-riscv64.tar.gz
mv go /usr/local/
binpath=$(echo $PATH | grep "/usr/local/go/bin")
if [[ "$binpath" == "" ]]
then
	echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
fi
source /etc/profile


# 4. install docker

if [ ! -d Docker ]; then
	mkdir Docker
fi
tar zxf docker-19.03.8-dev_riscv64.tar.gz -C Docker
cp Docker/etc/systemd/system/* /etc/systemd/system
cp Docker/usr/local/bin/* /usr/local/bin
cp Docker/usr/local/include/* /usr/local/include
cp -r Docker/usr/local/lib/* /usr/local/lib
cp Docker/usr/local/share/man/man1/* /usr/local/share/man/man1
cp Docker/usr/local/share/man/man3/* /usr/local/share/man/man3
cp -r Docker/docker /etc/

# 4. install CNI plugins
if [ ! -d plugins ]; then
	git clone https://github.com/containernetworking/plugins.git
fi
./plugins/build_linux.sh

if [ ! -d /etc/cni/net.d ]; then
mkdir -p /etc/cni/net.d
fi

if [ ! -f /etc/cni/net.d/10-mynet.conf ]; then
	cat >/etc/cni/net.d/10-mynet.conf <<EOF
{
    "cniVersion": "0.2.0",
    "name": "mynet",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.22.0.0/16",
        "routes": [
            { "dst": "0.0.0.0/0" }
        ]
    }
}
EOF
fi

if [ ! -f /etc/cni/net.d/99-loopback.conf ]; then
	cat >/etc/cni/net.d/99-loopback.conf <<EOF
{
    "cniVersion": "0.2.0",
    "name": "lo",
    "type": "loopback"
}
EOF
fi

cnipath=`pwd`
cnipath=$cnipath/plugins/bin
binpath=$(echo $CNI_PATH | grep cnipath)
if [[ "$binpath" == "" ]]
then
        echo "export CNI_PATH=$cnipath" >> /etc/profile
fi
source /etc/profile

# 5. set LD_LIBRARY_PATH
ldlibpath=$(echo $LD_LIBRARY_PATH | grep "/usr/local/lib")
if [[ "$ldlibpath" == "" ]]
then
	echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> /etc/profile
fi
source /etc/profile
/sbin/ldconfig

# 6. add docker group
egrep docker /etc/group >& /dev/null
if [ $? -ne 0 ]
then
	groupadd docker
fi

# 7. fake runc
if [ ! -f /usr/local/bin/runc ]; then
	ln -s /usr/local/bin/crun /usr/local/bin/runc
fi
