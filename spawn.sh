#!/bin/sh

set -eux

EXIT_CODE=0
AMI="ami-04e601abe3e1a910f"
SG="sg-03c0a0de6836d583d"
SUBNET="subnet-07ce3c81e409f4e14"

aws ec2 run-instances \
  --user-data "file://cloud-init.sh" \
  --image-id $AMI \
  --count 1 \
  --instance-type t3.micro \
  --key-name devops \
  --security-group-ids $SG \
  --subnet-id $SUBNET \
  --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":20,\"DeleteOnTermination\":true}}]" \
  --instance-initiated-shutdown-behavior terminate \
  --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value="Drill"}]" || EXIT_CODE=1
