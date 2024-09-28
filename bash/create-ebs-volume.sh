#!/bin/bash

# Replace <your-availability-zone>, <instance-id> with your actual values
AVAILABILITY_ZONE="<your-availability-zone>"
INSTANCE_ID="<instance-id>"

# 1.1 Create the EBS volume
echo "Creating EBS volume..."
VOLUME_ID=$(aws ec2 create-volume \
  --volume-type gp2 \
  --size 1 \
  --availability-zone $AVAILABILITY_ZONE \
  --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=My Volume}]' \
  --query 'VolumeId' \
  --output text)

echo "EBS volume created with ID: $VOLUME_ID"

# Wait for the volume to be available
echo "Waiting for the volume to be available..."
aws ec2 wait volume-available --volume-ids $VOLUME_ID

# 1.2 List your volumes to confirm creation
echo "Listing volumes in availability zone $AVAILABILITY_ZONE..."
aws ec2 describe-volumes --filters "Name=availability-zone,Values=$AVAILABILITY_ZONE"

# 2.2 Attach the volume to the instance
echo "Attaching volume $VOLUME_ID to instance $INSTANCE_ID..."
aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sdf

echo "Volume $VOLUME_ID has been attached to instance $INSTANCE_ID."
