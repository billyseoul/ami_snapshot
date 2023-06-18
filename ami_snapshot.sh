#!/bin/bash

## how to run the script:
## ./ami_snapshot.sh --instace=<instance_id> --bucket=<bucket_name>

# Checks if the user is already logged in
aws sts get-caller-identity &> /dev/null
if [ $? -ne 0 ]; then
  echo "You are not logged in to AWS."
  echo "Please run 'aws configure' or 'aws configure --profile <profile_name>' to log in."
  exit 1
fi

# Parses the command line arguments the user inputs.
# It should extract the instance ID and bucket name the user inputs as arguments.
# It will provide and error message for unknown options and exit
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --instance)
    INSTANCE_ID="$2"
    shift # past argument
    shift # past value
    ;;
    --bucket)
    BUCKET_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Unknown option '$key'"
    exit 1
    ;;
esac
done

# After accepting the arguments from the while loop, it takes an EC2 instance snapshot and waits for it to complete.
SNAPSHOT_ID=$(aws ec2 create-snapshot --description "Automated snapshot" --instance-id ${INSTANCE_ID} --query 'SnapshotId' --output text --wait)

# This should store the recently taken snapshot and upload it to the associated S3 bucket
aws s3 cp --content-length 0 /dev/null s3://${BUCKET_NAME}/${SNAPSHOT_ID}.img --sse

# Output confirmation of snapshot and where it's stored.
echo "Snapshot of instance ${INSTANCE_ID} taken and stored in S3 bucket ${BUCKET_NAME}"
