#!/bin/bash

# Carlos Gómez-Huélamo - September 2020

# File to launch a docker image using a specific image (first argument), with a certain container name (second arg.), user (third arg.) and number of tabs (fourth arg.).

# Example: ./launch_docker_image.sh my_docker_image:last my_container_name my_user 4

# N.B. If this user was not previously included in the docker image, first enter as root and include this user:

	# ./launch_docker_image.sh my_docker_image:last my_container_name root

	# (Docker image) sudo useradd -m my_user (-m option creates the home directory for that user)
        # (Docker image) sudo passwd my_user -> (Enter your password for this user)
        
        # Open new host tab -> docker commit my_container my_image

        # Now you can use your new user (with its corresponding home directory)

# Note: Do not include empty volumes in the docker run command. In that case (e.g. aux1="", -v $aux1), it will generate the following error: 

#        docker: invalid reference format: repository name must be lowercas 

# 1. Set named volumes

shared=""

if [[ $3 != "root" ]]; # Non-root user
then
	shared=$HOME/shared_home:/home/$3/shared_home
else                   # Root user
        
	shared=$HOME/shared_home:/$3/shared_home
fi

if [[ $1 == "perception_githubs:last" ]]; # Perception GitHubs image
then
	aux1=/media/robesafe/Data_RobeSafe/2D_MOT:/home/robesafe/perception_githubs/deepmot/test_tracktor/2D_MOT	
fi

if [[ $1 == "uahrobesafe/carla-challenge:last" ]]; # CARLA challenge image
then
        shared=$HOME/shared_home:/workspace/shared_home
	aux1=$HOME/robesafe_code:/workspace/team_code	
fi

# 2. Kill previous container 

docker stop $2 
docker rm -fv $2

echo "Image name: " $1
echo "Container name: " $2
echo "User: " $3
echo "Number of tabs: " $4

# 3. Run container 

if [[ $4 -gt 0 ]]; # Multiple tabs
then
	for (( i=1; i<=$4; i++ ))
	do 
		command=""
		if [[ $i -eq 1 ]]; 
		then 
			command="docker run -it --net host --name=$2 --privileged -u $3 -v /tmp/.X11-unix:/tmp/.X11-unix -v $shared -e DISPLAY=unix$DISPLAY $1 /bin/bash"
		else
			command="bash -c 'docker exec -it $2 /bin/bash'"
		fi

		gnome-terminal --tab "$i" -e "$command"
	done
else 	           # Single tab
	docker run -it --net host --name=$2 --privileged -u $3 -v /tmp/.X11-unix:/tmp/.X11-unix -v $shared -e DISPLAY=unix$DISPLAY $1 /bin/bash
fi

# -v $aux1
# --runtime=nvidia
