#!/bin/bash
set -e

# ----- Update and Upgrade -----
sudo apt update -y 

#-- wget to download files
sudo apt install wget -y


# --- Install gcc, g++, make, dpkg-dev, libc6-dev, binutils--
sudo apt install build-essential -y

# --- Install strace ---
sudo apt install strace -y

#-- gdb----
sudo apt install gdb -y

#--- clang ---
sudo apt install clang -y

# ----- CMake 3.30.2 -----
wget https://github.com/Kitware/CMake/releases/download/v3.30.2/cmake-3.30.2-linux-x86_64.sh
sudo sh cmake-3.30.2-linux-x86_64.sh --prefix=/usr/local --skip-license
rm cmake-3.30.2-linux-x86_64.sh

# ----- Ninja 1.10.0 -----
sudo apt install ninja-build -y

# ---- Install lcov ----
sudo apt install lcov -y

# --- Install heaptrack
sudo apt install heaptrack -y

# ---- Google Benchmark ----
# Check out the library.
git clone https://github.com/google/benchmark.git
# Go to the library root directory
cd benchmark
# Make a build directory to place the build output.
cmake -E make_directory "build"
# Generate build system files with cmake, and download any dependencies.
cmake -E chdir "build" cmake -DBENCHMARK_DOWNLOAD_DEPENDENCIES=on -DCMAKE_BUILD_TYPE=Release ../
# Build the library.
cmake --build "build" --config Release
# Run tests
cmake -E chdir "build" ctest --build-config Release
# Install the library.
sudo cmake --build "build" --config Release --target install
# Clean up
cd ..
rm -rf benchmark

# ---- Install perf ---- Fails on WSL
sudo apt install linux-tools-common linux-tools-generic linux-tools-$(uname -r) -y


