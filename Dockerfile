# Docker file for a ROS Melodic environment with kinova-ros package for running Kinova Jaco 2 Arm

FROM ros:melodic


# Replace 1000 with your user / group id
RUN export uid=4500 gid=1800 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

EXPOSE 9030

RUN apt-get update && apt-get install -y \
    python \
    python-tk \
    git \
    python-pip \
    vim \
    build-essential \
    unzip \
    wget \
    libglfw3 \
    libglew2.0 \
    libgl1-mesa-glx \
    libosmesa6 \
    libblas-dev \
    liblapack-dev \
    screen \
    man \
    net-tools \
    openssh-client \
    ssh \ 
    netcat \ 
    iputils-ping \
    rsync 

RUN apt-get install -y \
    ros-melodic-moveit \
    ros-melodic-tf-conversions \
    ros-melodic-trac-ik \
    ros-melodic-eigen-conversions \
    ros-melodic-ros-control \
    ros-melodic-ros-controllers \
    ros-melodic-robot-state-publisher

RUN pip install scipy
RUN pip install ipython
RUN pip install pid
RUN pip install numpy
RUN pip install matplotlib

# Source ROS setup.bash
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash" 

# Make and initialize the catkin_ws
RUN mkdir -p ~/catkin_ws/src
RUN /bin/bash -c '. /opt/ros/melodic/setup.bash; cd ~/catkin_ws; catkin_make'
RUN /bin/bash -c "source ~/catkin_ws/devel/setup.bash"

# Clone and make the kinova-ros package
RUN cd ~/catkin_ws/src/ \
    && git clone https://github.com/Kinovarobotics/kinova-ros.git \
    && /bin/bash -c '. /opt/ros/melodic/setup.bash; cd ~/catkin_ws; catkin_make'

# Clone and make the ros_interface package
RUN cd ~/catkin_ws/src/ \
    && git clone https://github.com/johannah/ros_interface.git \
    && /bin/bash -c '. /opt/ros/melodic/setup.bash; cd ~/catkin_ws; catkin_make'

run echo 'source /opt/ros/melodic/setup.bash' >> /root/.bashrc
run echo 'source ~/catkin_ws/devel/setup.bash' >> /root/.bashrc
WORKDIR /root/catkin_ws/src
