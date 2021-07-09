# Autonoship_simulation
Autonoship simulator based on Gazebo and ROS


### 1. System Requirements

This simulation is built on [Ubuntu 20.04](https://releases.ubuntu.com/20.04/) and [ROS noetic](http://wiki.ros.org/noetic/Installation/Ubuntu). If you are looking for the Ubuntu 16.04 version, please go to [this branch](https://github.com/Autonoship/Autonoship_simulation/tree/ubuntu16.04). The Ubuntu can be either a real machine or a virtual machine.
Before start, please follow the link [ROS noetic](http://wiki.ros.org/noetic/Installation/Ubuntu) to install ROS noetic on a Ubuntu 20.04 first.

According to the link, open a terminal and run:

    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
    sudo apt update
    sudo apt install ros-noetic-desktop-full
    echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
    source ~/.bashrc
    sudo apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
    sudo apt install python3-rosdep
    sudo rosdep init
    rosdep update

### 2. install Gazebo

    sudo apt-get install libgazebo11-dev libignition-math6-dev

### 3. install tensorflow (placeholder)

The collision avoidance module will rely on the tensorflow.
    
### 4. install FMI-library

Install FMI Library according to https://github.com/modelon-community/fmi-library and https://jmodelica.org/fmil/FMILibrary-2.0.3-htmldoc/index.html, or try:

    cd 
    git clone https://github.com/modelon-community/fmi-library.git
    mkdir build-fmil; cd build-fmil
    cmake -DFMILIB_INSTALL_PREFIX=~/FMI_library ~/fmi-library
    make install test
    

### 5. Create Workspace & Environment Configuration

Download the /autonoship_simulation, /collision_avoidance and /usv_gazebo_plugins into the /home directory. In a terminal, run:
 
    mkdir -p ~/autonoship/src
    cd ~/autonoship/
    catkin_make

    git clone https://github.com/Autonoship/Autonoship_simulation.git
    mv Autonoship_simulation/autonoship_simulation/ Autonoship_simulation/collision_avoidance/ Autonoship_simulation/navigation_control/ Autonoship_simulation/usv_gazebo_plugins/ src

    sudo apt-get install ros-noetic-hector-gazebo-plugins ros-noetic-pid  

    catkin_make
    source devel/setup.bash
    echo  'source ~/autonoship/devel/setup.bash' >> ~/.bashrc 

    roscd autonoship_simulation
    cd scripts
    chmod +x key_publisher.py keys_to_rudder.py radar_reader.py radar_tracking.py setpoint_pub.py state_reader.py target_state.py true_state.py

    roscd collision_avoidance
    cd scripts
    chmod +x predict_action.py

    pip install pyyaml
    echo  'export GAZEBO_RESOURCE_PATH=~/autonoship/src/usv_gazebo_plugins/fmu:$GAZEBO_RESOURCE_PATH' >> ~/.bashrc 
    
    pip install scipy
    pip install matplotlib
    pip install pygame
    pip install pymunk==4.0.0
    pip install pyyaml

### 6. Install FMI Adapter

    sudo apt-get install ros-noetic-fmi-adapter

### 7. Usage

To test the collision avoidance module, run scenario 1:

    roslaunch autonoship_simulation autonoship_gazebo.launch scenario:=scenario1
    
To run a certain testing scenario (e.g. scenario8), run:
    
    roslaunch autonoship_simulation autonoship_gazebo.launch scenario:=scenario8

to run the PID autopilot, run: 

    roslaunch autonoship_simulation autonoship_gazebo scenario:=scenario1 autopilot:=PID
    
To control targetships, publish message in the terminal:

    rostopic pub targetship1/u2 std_msgs/Float64 10000000
    
To test the radar module, echo the radar feedback in the terminal:

    rostopic echo ownship/logical_camera

To change the RPM of the radar to 80, run in a terminal:

    rostopic pub ownship/rpm std_msgs/Float64 80
    
To test the radar tracking module, echo the state of a targetship (e.g. targetship1):

    rostopic echo ownship/targetship1/
    
