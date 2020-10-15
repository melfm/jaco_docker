# Docker file for a ROS Melodic environment with kinova-ros package for running Kinova Jaco 2 Arm

FROM ros:melodic

# nvidia-container-runtime
# For running Rviz
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# Replace 1000 with your user / group id
RUN export uid=4500 gid=1800 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

EXPOSE 9030
EXPOSE 9031

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
    rsync  \
    usbutils \
    software-properties-common

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

RUN echo 'source /opt/ros/melodic/setup.bash' >> /root/.bashrc
RUN echo 'source ~/catkin_ws/devel/setup.bash' >> /root/.bashrc


#### REALSENSE CAMERA
# Install instructions for realsense camera from https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_linux.md#installing-the-packages 
RUN apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE ||  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
RUN add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo bionic main" -u
RUN sudo apt-get install -y \
            librealsense2-dkms \ 
            librealsense2-utils \
            librealsense2-dev \
            librealsense2-dbg \
            ros-melodic-diagnostic-updater \ 
            ros-melodic-ddynamic-reconfigure

# install realsense ROS https://github.com/IntelRealSense/realsense-ros
RUN cd ~/catkin_ws/src/ \
    && git clone https://github.com/IntelRealSense/realsense-ros.git && cd realsense-ros/

RUN /bin/bash -c '. /opt/ros/melodic/setup.bash; cd ~/catkin_ws; catkin_make -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release; catkin_make install'


WORKDIR /root/catkin_ws/src
