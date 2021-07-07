FROM dorowu/ubuntu-desktop-lxde-vnc:focal
ENV DISTRO noetic

ENV DEBIAN_FRONTEND noninteractive
RUN echo "Set disable_coredump false" >> /etc/sudo.conf

RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq wget curl git terminator build-essential vim sudo lsb-release locales bash-completion tzdata gosu && \
    rm -rf /var/lib/apt/lists/*

ENV USER ubuntu

RUN useradd --create-home --home-dir /home/${USER} --shell /bin/bash --user-group --groups adm,sudo ${USER} && \
    echo ubuntu:ubuntu | chpasswd && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers



# 1. System Requirements
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -k https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo apt-key add -
RUN sudo apt-get update || echo ""
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq ros-${DISTRO}-desktop-full && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq python3-rosdep && \
    rm -rf /var/lib/apt/lists/*
RUN sudo rosdep init && rosdep update
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq python3-rosinstall python3-rosinstall-generator python3-wstool build-essential python3-vcstool && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq python3-catkin-tools python3-osrf-pycommon && \
    rm -rf /var/lib/apt/lists/*

# 2. Install Gazebo
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq libgazebo11-dev libignition-math6-dev && \
    rm -rf /var/lib/apt/lists/*

# 3. Install Tensorflow (placeholder)
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq python3-dev python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*
RUN pip install --user --upgrade tensorflow

# 4. Install FMI-library
WORKDIR /home/${USER}
RUN git clone --depth 1 https://github.com/modelon-community/fmi-library.git
RUN mkdir build-fmil && cd build-fmil
WORKDIR /home/${USER}/build-fmil
RUN cmake -DFMILIB_INSTALL_PREFIX=~/FMI_library ~/fmi-library
RUN make install test

# 5. Install FMI Adapter
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq ros-noetic-fmi-adapter && \
    rm -rf /var/lib/apt/lists/*

# 6. Create Workspace & Environment Configuration
ENV WORKSPACE autonoship
RUN mkdir -p /home/${USER}/${WORKSPACE}/src
WORKDIR /home/${USER}/${WORKSPACE}
RUN . /opt/ros/${DISTRO}/setup.sh && catkin_make

RUN git clone --depth 1 https://github.com/Autonoship/Autonoship_simulation.git
RUN mv /home/${USER}/${WORKSPACE}/Autonoship_simulation/* /home/${USER}/${WORKSPACE}/src

RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq ros-noetic-hector-gazebo-plugins ros-noetic-pid && \
    rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/${DISTRO}/setup.sh && catkin_make

RUN chmod +x /home/${USER}/${WORKSPACE}/src/autonoship_simulation/scripts/*.py
RUN chmod +x /home/${USER}/${WORKSPACE}/src/collision_avoidance/scripts/*.py

RUN pip install pyyaml
RUN echo 'export GAZEBO_RESOURCE_PATH=/home/'${USER}'/'${WORKSPACE}'/src/usv_gazebo_plugins/fmu:$GAZEBO_RESOURCE_PATH' >> ~/.bashrc

RUN pip install pygame
RUN pip install pymunk==4.0.0