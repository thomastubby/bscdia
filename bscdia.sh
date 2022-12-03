#by: Tom Stein

#!/bin/bash
user="root"
echo "What is the user? (default: root)"
read username
if [ "$username" = "" ]
	then username="root"
fi
echo "User: $username"
echo "What is the IP of the server? "
read userip
showDate=(date +"%m-%d-%Y @ %H:%M:%S")

ssh -tt $username@$userip <<\EOF

##HIDES INPUT
stty -echo

##SYS INFO
cpuName=$(lscpu | grep "Model name:" | xargs)
cpuCores=$(lscpu | grep "CPU(s):" | grep -v "NUMA" | xargs)
gpuName=$(lspci | grep "VGA compatible controller" | cut -d " " -f 5-)
ram=$(free -h | grep "Mem:" | xargs)
hdd=$(df -h | grep "/dev/")
publicip=$(curl -s ifconfig.me && echo | xargs)
localip=$(ifconfig | grep -A 2 "flags")
user=$(whoami)
workingOS=$(cat /etc/os-release | grep -A 1 -w "NAME=" | cut -d "\"" -f 2)
showDate=$(date +"%m-%d-%Y @ %H:%M:%S")
uptime=$(uptime -p)

##NETWORK
checkGip=$(ping -c 1 8.8.8.8 | grep "1 received," | xargs | cut -d " " -f 4,5)
checkCip=$(ping -c 1 1.1.1.1 | grep "1 received," | xargs | cut -d " " -f 4,5)
checkGdom=$(ping -c 1 google.com | grep "1 received," | xargs | cut -d " " -f 4,5)
checkCdom=$(ping -c 1 cloudflare.com | grep "1 received," | xargs | cut -d " " -f 4,5)
## IP CHECK
if [ "$checkGip" = "1 received," ];
        then Gip="success"
else Gip="failure"
fi
if [ "$checkCip" = "1 received," ];
        then Cip="success"
else Cip="failure"
fi
if [ $Gip = "success" ] && [ $Cip = "success" ];
        then networkStatus="Network success"
else networkStatus="Partial network failure"
fi

##DNS CHECK
if [ "$checkGdom" = "1 received," ];
        then gDom="success"
else gDom="failure"
fi
if [ "$checkCdom" = "1 received," ];
        then cDom="success"
else cDom="failure"
fi
if [ $gDom = "success" ] && [ $cDom = "success" ];
        then dnsStatus="DNS success"
else dnsStatus="DNS failure"
fi

clear
cat <<limit
|===========================================================|
| ________  ________  ________  ________  ___  ________     |
||\   __  \|\   ____\|\   ____\|\   ___ \|\  \|\   __  \    |
|\ \  \|\ /\ \  \___|\ \  \___|\ \  \_|\ \ \  \ \  \|\  \   |
| \ \   __  \ \_____  \ \  \    \ \  \ \\\ \ \  \ \   __  \  |
|  \ \  \|\  \|____|\  \ \  \____\ \  \_\\\ \ \  \ \  \ \  \ |
|   \ \_______\____\_\  \ \_______\ \_______\ \__\ \__\ \__\|
|    \|_______|\_________\|_______|\|_______|\|__|\|__|\|__||
|             \|_________|                                  |
|=================TOOL-CREATED-BY-TOM-STEIN=================|

$showDate
User: $user
System uptime: $uptime

-----OS------
$workingOS

-----CPU-----
$cpuName
$cpuCores

-----GPU-----
$gpuName

-----RAM-----
$ram

-----HDD-----
$hdd

---Network---
Google Link: $Gip
Cloudflare Link: $Cip
-=$networkStatus=-

Google DNS: $gDom
Cloudflare DNS: $cDom
-=$dnsStatus=-

Public: $publicip
Interfaces: 
$localip
-------------
limit
logout
EOF
