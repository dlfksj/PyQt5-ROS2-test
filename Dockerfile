FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu20.04

# Dependencies for glvnd and X11
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
ENV QT_X11_NO_MITSHM 1
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
    libglvnd0 libgl1 libglx0 libegl1 \
    libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev \
    libxext6 libx11-6 \
    mesa-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Basic Tools
RUN apt-get update && apt-get install -y \
    vim \
    git \
    net-tools \
    wget \
    unzip \
    tar \
    rsync \
    apt-utils \
    && rm -rf /var/lib/apt/lists/* 

# Install languages
RUN apt-get update
RUN apt-get install -y locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Install timezone
ENV TZ=Asia
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install ROS2
ENV ROS_DISTRO=galactic
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y 
RUN apt install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    sudo
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get update \
    && apt-get upgrade \
    && apt-get install -y ros-$ROS_DISTRO-desktop python3-argcomplete \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \ 
    gdb \
    libbullet-dev \
    python3-colcon-common-extensions \
    python3-flake8 \
    python3-pip \
    python3-pytest-cov \
    python3-rosdep \
    python3-setuptools \
    python3-vcstool \
    python3-dev \
    pylint3

RUN python3 -m pip install -U \
    argcomplete \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-docstrings \
    flake8-import-order \
    flake8-quotes \
    pytest-repeat \
    pytest-rerunfailures \
    pytest

RUN apt-get install --no-install-recommends -y \
    libasio-dev \
    libtinyxml2-dev \
    libcunit1-dev

ENV AMENT_PREFIX_PATH=/opt/ros/$ROS_DISTRO
ENV COLCON_PREFIX_PATH=/opt/ros/$ROS_DISTRO
ENV LD_LIBRARY_PATH=/opt/ros/$ROS_DISTRO/lib
ENV PATH=/opt/ros/$ROS_DISTRO/bin:$PATH
ENV PYTHONPATH=/opt/ros/$ROS_DISTRO/lib/python3.8/site-packages

RUN rosdep init
RUN rosdep update


# Build imu_gps_navigation package
WORKDIR /gcs_ws
COPY ./src /gcs_ws/src
RUN . /opt/ros/$ROS_DISTRO/setup.sh && colcon build --symlink-install

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
RUN echo "source /root/gcs_ws/install/setup.bash" >> ~/.bashrc

