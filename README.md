# AMI Snapshot Script

This script should allow you to create an Amazon Machine Image (AMI) snapshot of an EC2 instance and store it in an S3 bucket. 

You have to have the AWS CLI configured on your machine along with your credentials for this to work. 

The script takes two command line arguments:

- --ami : The AMI ID of the AMI you want to take a snapshot of.

- --bucket : The name of the S3 bucket you want to store the snapshot in.

To run the script:
```python
./ami_snapshot.sh --ami <ami_ID> --bucket <s3_bucket_name>
```
The script will check if you're logged in to AWS and will prompt you to log in if you're not.
The script will take a snapshot of the AMI and store it in the S3 bucket that the user entered. 
If no input was accpeted, the script should exit.

The script will then delete the local snapshot file and output confirmation that a snapshot was taken and stored in the S3 bucket you entered.

