#!/bin/bash


## how to run the script:
## ./ami_snapshot.sh --ami=<ami_id> --bucket=<bucket_name>

# If a command returns a non-zero status, it should exit out the script
set -e

# Checks if the user is already logged in
aws sts get-caller-identity &> /dev/null
if [ $? -ne 0 ]; then
  echo "You're currently not logged into your AWS account."
  echo "Please run 'aws configure' or 'aws configure --profile <profile_name>' to log in."
  exit 1
fi

# Parses the command line arguments the user inputs.
# It should extract the instance ID and bucket name the user inputs as arguments.
# It will output an error message for unknown options and exit
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --ami)
    AMI_ID="$2"
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

# Take AMI snapshot
SNAPSHOT_ID=$(aws ec2 create-image --instance-id ${AMI_ID} \
                                   --name "${AMI_ID}-snapshot" \
                                   --description "Automated snapshot" \
                                   --block-device-mappings "[{ \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"DeleteOnTermination\": false, \"VolumeType\": \"gp2\" }}]" \
                                   --output text)

# Wait for the snapshot to complete
aws ec2 wait image-available --image-ids ${SNAPSHOT_ID}

# Store the snapshot in the S3 bucket entered
aws s3 cp "${SNAPSHOT_ID}.img" "s3://${BUCKET_NAME}/${SNAPSHOT_ID}.img"

# Delete the local snapshot file
rm "${SNAPSHOT_ID}.img"

# Get the current date and time
SNAPSHOT_DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Output confirmation
echo "Snapshot of AMI ${AMI_ID} taken ${SNAPSHOT_DATE} and stored in S3 bucket ${BUCKET_NAME}"
