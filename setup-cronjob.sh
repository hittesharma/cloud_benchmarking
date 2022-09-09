#!/bin/sh

### THIS SCRIPT ARE JUST NOTES; NOT A REAL EXECUTABLE

sudo apt-get update && sudo apt-get install -y sysbench

sudo mkdir -p /var/lib/cc


# Copy benchmark.sh to /var/lib/cc/benchmark.sh
sudo chmod 755 /var/lib/cc/benchmark.sh
sudo chown root:root /var/lib/cc/benchmark.sh

# Setup result.csv
echo "time,cpu,mem,diskRand,diskSeq" | sudo tee /var/lib/cc/result.csv
sudo chmod 644 /var/lib/cc/result.csv
sudo chown ubuntu:ubuntu /var/lib/cc/result.csv

# Add the following line to /etc/crontab
# I know ubuntu is in the sudoers, but I am not lazy to setup a new user for this assignmnet
0,30 * * * * ubuntu /var/lib/cc/benchmark.sh >> /var/lib/cc/result.csv