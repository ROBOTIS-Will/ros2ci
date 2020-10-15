#!/bin/bash
# Copyright 2019 Mikael Arguedas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

function install_dependencies() {
# install dependencies
apt-get -qq update && rosdep update && rosdep install -y \
  --from-paths src \
  --ignore-src \
  --rosdistro $ROS_DISTRO
}

function build_workspace() {
colcon build \
    --symlink-install \
    --cmake-args -DSECURITY=ON --no-warn-unused-cli
}

function test_workspace() {

colcon test \
    --executor sequential \
    --event-handlers console_direct+
# use colcon test-result to get list of failures and return error code accordingly
colcon test-result
}

# if [[ "$ROS_DISTRO" == "foxy" ]]; then
#   echo "'$1' detected"
#   echo "install foxy packages"
#   git clone -b foxy-devel https://github.com/ROBOTIS-GIT/hls_lfcd_lds_driver.git
#   git clone -b foxy-devel https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
#   git clone -b dashing https://github.com/ros2/cartographer_ros.git
#   git clone -b foxy-devel https://github.com/ros-planning/navigation2.git
# fi

echo "install dependencies"
install_dependencies

echo "source setup.bash"
# source ROS_DISTRO in case newly installed packages modified environment
source /opt/ros/$ROS_DISTRO/setup.bash

echo "build workspace"
build_workspace
echo "test workspace"
test_workspace
