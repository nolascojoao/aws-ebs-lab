#!/bin/bash

# Stop execution on error
set -e

# Replace <volume-id>, <your-availability-zone>, and <instance-id> with your actual values
VOLUME_ID="volume-id"
AVAILABILITY_ZONE="your-availability-zone"
INSTANCE_ID="instance-id"

# Task 5: Creating an EBS snapshot
# 5.1 Create the snapshot
echo "Creating snapshot of volume $VOLUME_ID..."
SNAPSHOT_ID=$(aws ec2 create-snapshot \
  --volume-id $VOLUME_ID \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=My Snapshot}]' \
  --query 'SnapshotId' \
  --output text)

echo "Snapshot created with ID: $SNAPSHOT_ID"

# 5.2 Check the snapshot status
echo "Checking snapshot status for $SNAPSHOT_ID..."
aws ec2 wait snapshot-completed --snapshot-ids $SNAPSHOT_ID

echo "Snapshot $SNAPSHOT_ID is completed."

# Task 6: Restoring the snapshot to a new EBS volume
# 6.1 Create a new volume from the snapshot
echo "Creating new EBS volume from snapshot $SNAPSHOT_ID..."
NEW_VOLUME_ID=$(aws ec2 create-volume \
  --snapshot-id $SNAPSHOT_ID \
  --availability-zone $AVAILABILITY_ZONE \
  --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=Restored Volume}]' \
  --query 'VolumeId' \
  --output text)

echo "New volume created with ID: $NEW_VOLUME_ID"

# Wait for the new volume to be available
echo "Waiting for the new volume to be available..."
aws ec2 wait volume-available --volume-ids $NEW_VOLUME_ID

# 6.2 Attach the restored volume to the EC2 instance
echo "Attaching new volume $NEW_VOLUME_ID to instance $INSTANCE_ID..."
aws ec2 attach-volume --volume-id $NEW_VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sdg

echo "Volume $NEW_VOLUME_ID has been attached to instance $INSTANCE_ID."
