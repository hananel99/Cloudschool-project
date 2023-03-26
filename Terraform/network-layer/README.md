# Workshop-Site
This repo creates a "site" module with all the nessesary resources for the Network layer 

## What are we provisioning here?
- VPC and Gateway resources
- subnets
- an admin RSA public key (for SSH connection to the instances)

## Assignment

Fork and clone / copy the content of this repository, and complete the tasks below (work closely with the terraform documentation):

1. Create the prerequisite resources for the backend (AWS bucket+folger, dynamodb table) using the AWS console

1. Complete the aws_key_pair resource.

2. Complete the VPC module, mind this requirements:
	a. The inter-domain address range should be: 16382.
	b. The address range should be equally distributed between the public-subnet and the private-subnet.

3. Complete all the missing values (marked with "???")

4. Deploy the VPC module
