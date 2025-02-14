#!/usr/bin/env bash

#:: Adeptio dev team
#:: Copyright // 2018-08-20
#:: Version: v1.0.0.2
#:: Tested on Ubuntu 18.04 LTS Server Bionic only!

cat << "ADE"

           _____  ______        __   ___   ___   ___
     /\   |  __ \|  ____|      /_ | / _ \ / _ \ |__ \
    /  \  | |  | | |__    __   _| || | | | | | |   ) |
   / /\ \ | |  | |  __|   \ \ / / || | | | | | |  / /
  / ____ \| |__| | |____   \ V /| || |_| | |_| | / /_
 /_/    \_\_____/|______|   \_/ |_(_)___(_)___(_)____|

ADE

echo "== adeptio v1.0.0.2 =="
echo
echo "Good day. This is automated hot masternode setup for adeptio coin. Auto installer was tested on specific environment. Don't try to install masternode with undocumented operating system!"
echo
echo "This setup can be launched only once"
echo "Do you agree? y/n"
read agree
            if [ "$agree" != "y" ]; then
               echo "Sorry, we cannot continue" && exit 1
            fi
OS_version=$(cat /etc/lsb-release | grep -c bionic)
            if [ "$OS_version" -ne "1" ]; then
                    echo ""
                    echo "Looks like your OS version is not Ubuntu 18.04 Bionic" && exit 1
            fi
sudo apt-get install dnsutils -y
echo ""
wanip=$(/usr/bin/dig +short myip.opendns.com @resolver1.opendns.com)
echo "Your external IP is $wanip y/n?"
read wan
            if [ "$wan" != "y" ]; then
               echo "Sorry, we don't know your external IP" && exit 1
            fi
# Check if bitcoin repo exists //
[ -f /etc/apt/sources.list.d/bitcoin-ubuntu-bitcoin-bionic.list ]
            if [ "$?" -eq "0" ]; then
                    echo ""
                    echo "Looks like you are trying to setup second time? You need a fresh installation!" && exit 1
            fi
# Install dep. //
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev  bsdmainutils software-properties-common libminiupnpc-dev libcrypto++-dev libboost-all-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git software-properties-common unzip libzmq3-dev ufw wget -y

# Download adeptio sources //
cd ~
rm -fr adeptio*.zip
wget https://github.com/adeptio-project/adeptio/releases/download/v1.0.0.2/adeptiod-v1.0.0.2.zip

# Manage coin daemon and configuration //
unzip -o adeptio*.zip
echo ""
sudo cp -fr adeptio-cli adeptiod /usr/bin/
mkdir -p ~/.adeptio/
touch ~/.adeptio/adeptio.conf
cat << EOF > ~/.adeptio/adeptio.conf
rpcuser=adeptiouser
rpcpassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')
rpcallow=127.0.0.1
server=1
listen=1
daemon=1
staking=1
addnode=202.182.106.136
addnode=23.225.207.13
addnode=78.61.18.211
addnode=89.47.163.190
addnode=94.244.97.73
addnode=14.162.125.233
addnode=18.219.217.30
addnode=45.77.46.169
addnode=80.211.17.134
addnode=142.93.42.61
addnode=173.82.245.209
addnode=85.255.9.40
addnode=90.154.10.51
addnode=149.28.157.130
addnode=207.246.91.171
addnode=31.14.134.194
addnode=94.177.161.102
addnode=90.154.10.54
addnode=103.27.237.206
addnode=[2001:470:71:e89:20c:29ff:fea6:b8fe]
addnode=[2001:bc8:3d74:100::11]
addnode=[2001:bc8:3d74:100::4]
addnode=[2001:470:71:39:f816:3eff:fe70:77ab]
addnode=[2001:470:71:35f:f816:3eff:fec9:3a7]
EOF

# Start adeptio daemon, wait for wallet creation and get the masterprivkey and addr where to send 10 000 ADE //
/usr/bin/adeptiod --daemon &&
echo "" ; echo "Please wait for few minutes..."
sleep 120 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
masternodeaddr=$(/usr/bin/adeptio-cli getnewaddress)
masternodeprivkey=$(/usr/bin/adeptio-cli masternode genkey)
echo ""
echo "Your masternode wallet addr is -: $masternodeaddr :- Send exactly 10 000 ADE to this address"
masternodeprivkey=$(/usr/bin/adeptio-cli masternode genkey)
while :
do
req_coins=$(/usr/bin/adeptio-cli getwalletinfo | grep balance | grep -oP '.*?(?=\.)' | awk -F'[^0-9]*' '$0=$2')
        if [ "$req_coins" = "10000" ]
        then
                break
        fi
        echo ""
        echo "Adeptio balance is not 10 000 coins."
	echo ""
        echo "Checking again in 60 seconds..." && sleep 60
done
echo ""
echo "All set. Adeptio balance is 10 000 coins!"  
echo ""
/usr/bin/adeptio-cli stop &&
echo ""
echo "Shutting down daemon, reconfiguring adeptio.conf, adding masternodeprivkey and enabling masternode option"
echo ""
echo "Give some time to shutdown the wallet..."
echo ""
sleep 60 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
cat << EOF > ~/.adeptio/adeptio.conf
rpcuser=adeptiouser
rpcpassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')
rpcallow=127.0.0.1
server=1
listen=1
daemon=1
staking=1
maxconnections=125
masternode=1
masternodeaddr=$wanip:9075
externalip=$wanip
masternodeprivkey=$masternodeprivkey
addnode=202.182.106.136
addnode=23.225.207.13
addnode=78.61.18.211
addnode=89.47.163.190
addnode=94.244.97.73
addnode=14.162.125.233
addnode=18.219.217.30
addnode=45.77.46.169
addnode=80.211.17.134
addnode=142.93.42.61
addnode=173.82.245.209
addnode=85.255.9.40
addnode=90.154.10.51
addnode=149.28.157.130
addnode=207.246.91.171
addnode=31.14.134.194
addnode=94.177.161.102
addnode=90.154.10.54
addnode=103.27.237.206
addnode=[2001:470:71:e89:20c:29ff:fea6:b8fe]
addnode=[2001:bc8:3d74:100::11]
addnode=[2001:bc8:3d74:100::4]
addnode=[2001:470:71:39:f816:3eff:fe70:77ab]
addnode=[2001:470:71:35f:f816:3eff:fec9:3a7]
EOF

# Firewall //
echo "Update firewall rules"
sudo /usr/sbin/ufw limit ssh/tcp comment 'Rate limit for openssh serer' 
sudo /usr/sbin/ufw allow 9075/tcp
sudo /usr/sbin/ufw --force enable
echo ""

# Start daemon after reboot //
echo "Update crontab"
crontab -l | { cat; echo "@reboot /usr/bin/adeptiod --daemon"; } | crontab -
echo "Crontab update done"

# Final start
echo ""
echo "Masternode config done, starting daemon again"
echo ""
/usr/bin/adeptiod --daemon
echo ""
echo "Setup almost completed. You have to wait 15 confirmations right now"
echo ""
echo "Setup summary:"
echo "Masternode Wallet Addr: $masternodeaddr"
echo "Masternode privkey: $masternodeprivkey"
echo "Your external IP: $wanip"
echo "Your wallet located in ~$HOME/.adeptio/wallet.dat Please backup it after setup!"
echo ""
echo "" ; echo "Verifying blocks, waiting for 15 confirmations. Please wait ~22 minutes..."
sleep 1320 &
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
/usr/bin/adeptio-cli masternode start
sleep 5
echo ""
echo "Checking masternode status:"
/usr/bin/adeptio-cli masternode status
