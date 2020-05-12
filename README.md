# Kinova Jaco 2 Arm Docker
Dockerfile for running Kinova Jaco 2 without any ROS installed on the machine. 
Tested on Ubuntu 18.04.

## Instructions 
* Install Docker from [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/), and follow the instructions [here](https://docs.docker.com/install/linux/linux-postinstall/) to run `docker` without `sudo` access. 

* Pull the `ros:melodic` container from Docker
```
docker pull ros:melodic
```

* Clone this repo into `~/workspace` and build the docker image:
```
mkdir ~/workspace && cd ~/workspace
git clone https://github.com/sahandrez/jaco_docker.git
docker build --tag jaco_control .
```

* To access the arm via USB copy the udev srule file `10-kinova-arm.rules` from `/udev` to 
`/etc/udev/rules.d` and then connect the robot to your machine: 
```
# From /jaco_docker
sudo cp udev/10-kinova-arm.rules /etc/udev/rules.d/
```

* Run the Docker container with access to the USB devices for establishing connection to the robot: 
```
docker run -it --name jaco_robot --privileged -v /dev/bus/usb:/dev/bus/usb  jaco_control
```

* You can now run the robot from inside the Docker regularly as if you had ROS installed on your 
machine. In order to connect to the running container use the following command:
```
docker exec -it jaco_robot /bin/bash
```

## Notes:

source of ros and catkin dir did not seem to work
