#!/bin/bash
# minecraft server update script

# read the settings
. ./server.settings

# change to serverdirectory
cd ${serverdirectory}

# check if server is running
if ! screen -list | grep -q "${servername}"; then
		echo -e "${yellow}Server is not currently running!${nocolor}"
		exit 1
fi

# countdown
counter="60"
while [ ${counter} -gt 0 ]; do
		if [[ "${counter}" =~ ^(60|40|20|10|5|4|3|2|1)$ ]];then
				echo "server is updating in ${counter} seconds!"
				screen -Rd ${servername} -X stuff "say server is updating in ${counter} seconds!$(printf '\r')"
		fi
counter=$((counter-1))
sleep 1s
done

# server stop
echo "stopping server..."
screen -Rd ${servername} -X stuff "say stopping server...$(printf '\r')"
screen -Rd ${servername} -X stuff "stop$(printf '\r')"

# check if server stopped
stopchecks="0"
while [ $stopchecks -lt 30 ]; do
		if ! screen -list | grep -q "${servername}"; then
				break
		fi
stopchecks=$((stopchecks+1))
sleep 1;
done

# force quit server if not stopped
if screen -list | grep -q "${servername}"; then
		echo -e "${yellow}Minecraft server still hasn't closed after 30 seconds, closing screen manually${nocolor}"
		screen -S ${servername} -X quit
fi

# Test internet connectivity and update on success
wget --spider --quiet -O minecraft_server.1.16.3.jar https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar
if [ "$?" != 0 ]; then
	echo -e "${red}Unable to connect to update website. Skipping update ...${nocolor}"
	else
	echo -e "${green}downloading newest server version...${nocolor}"
	wget -q -O minecraft_server.1.16.3.jar https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar
fi

# restart the server
echo -e "${green}restarting server...${nocolor}"
./start.sh
