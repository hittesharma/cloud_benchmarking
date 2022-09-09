#!/bin/sh

# Setting the user name environment variable
AWS_IAM_USER="elias"

# REQ 1: Ensures the existence of a default VPC
aws ec2 create-default-vpc

SSH_USER_NAME="$AWS_IAM_USER"
# Specifiying the ssh key path/name
SSH_USER_ID_PATH="id_rsa"

# REQ 0: Create an ssh key at the specified path (-f) with an user name associated to it (-C)
ssh-keygen \
	-N "" \
	-C "$SSH_USER_NAME" \
	-f "$SSH_USER_ID_PATH"

# The ssh key is imported into the EC2 management
aws ec2 import-key-pair \
	--key-name "$AWS_IAM_USER" \
	--public-key-material "$(cat "$SSH_USER_ID_PATH".pub)"

# Security Groups need a name and a description that is first specified…
SECURITY_GROUP="MySecurityGroup"
SECURITY_GROUP_DESCRIPTION="MySecurityGroup is used by create-aws.sh"

# …and then set up for the EC2 management (REQ 3)
aws ec2 create-security-group \
	--group-name "$SECURITY_GROUP" \
	--description "$SECURITY_GROUP_DESCRIPTION"

# Configure firewall allowing incoming ICMP (-1 refers to all types) and ssh traffic for every IPv4 address
aws ec2 authorize-security-group-ingress \
	--group-name "$SECURITY_GROUP" \
	--protocol tcp \
	--port 22 \
	--cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
	--group-name "$SECURITY_GROUP" \
	--protocol icmp \
	--port -1 \
	--cidr 0.0.0.0/0

# Finally (REQ 4), exactly one instance is started with the newest Amazon machine image and the desired t2.micro instance type.
# 	It is ensured, that the given key name is specified and the instance is associated to the right security group. The
#	necessary security group name is extracted by searching through all created security groups using the `grep` tool.
# 	The AMI refers to the current eu-central ubuntu image
aws ec2 run-instances \
	--image-id ami-09356619876445425 \
	--count 1 \
	--instance-type t2.micro \
	--key-name "$AWS_IAM_USER" \
	--security-groups "$SECURITY_GROUP" \

### Use the following line to add the crontab entry for periodic benchmarking
# echo '0,30 * * * * ubuntu /var/lib/cc/benchmark.sh >> /var/lib/cc/result.csv' | sudo tee -a /etc/crontab