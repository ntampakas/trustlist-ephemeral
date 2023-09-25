#!/bin/sh

set -eux

TRIGGER=$1
BRANCH=$2
AMI="ami-04e601abe3e1a910f"
SG="sg-03c0a0de6836d583d"
SUBNET="subnet-07ce3c81e409f4e14"
VPC="vpc-05dedcb650bd24f8d"

# Kill old instances
CURRENT_TIME_EPOCH=$(date -d `date -Is` +"%s")
EC2=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=[running]" "Name=tag:Name,Values='Drill'" "Name=network-interface.vpc-id,Values=[$VPC]" --query "Reservations[*].Instances[*].InstanceId" --output text)
for i in $EC2; do
  EC2_LAUNCH_TIME=$(aws ec2 describe-instances --instance-ids $i --query 'Reservations[*].Instances[*].LaunchTime' --output text)
  LAUNCH_TIME_EPOCH=$(date -d $EC2_LAUNCH_TIME +"%s")
  diff=$(expr $CURRENT_TIME_EPOCH - $LAUNCH_TIME_EPOCH)

  #if [ $diff -gt 43200 ]; then
  if [ $diff -gt 1000 ]; then
    aws ec2 terminate-instances --instance-ids $i
  fi
done

# Stop here in schedule
[ ! $TRIGGER = "maintenance" ] || exit 0

# Launch new instance
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
  --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value="Drill"}]"
  --metadata-options "Branch=$2,Repo=Drill"
