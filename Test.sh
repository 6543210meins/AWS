#!/bin/bash
# Create a VPC
AWS_VPC=$(aws ec2 create-vpc \
--cidr-block 10.0.0.0/16 \
--query 'Vpc.{VpcId:VpcId}' \
--output text)

# Add a name tag to the VPC
read -p "Bitte gebe einen Name für den VPC ein: " vpc_name
aws ec2 create-tags \
--resources $AWS_VPC \
--tags Key=Name,Value=$vpc_name

# Enable DNS hostnames
aws ec2 modify-vpc-attribute \
--vpc-id $AWS_VPC \
--enable-dns-hostnames "{\"Value\":true}"

# Enable DNS support
aws ec2 modify-vpc-attribute \
--vpc-id $AWS_VPC \
--enable-dns-support "{\"Value\":true}"

# Create a public subnet
read -p "Bitte gebe den namen deiner Availabilityzone ein (die endet mir einen buchstaben): " avail_zone
AWS_PUBLIC_SUBNET=$(aws ec2 create-subnet \
--vpc-id $AWS_VPC \
--cidr-block 10.0.1.0/24 \
--availability-zone $avail_zone \
--query 'Subnet.{SubnetId:SubnetId}' \
--output text)

# Add a name tag to the public subnet
read -p "Bitte gebe den Subnet namen ein: " public_name
aws ec2 create-tags \
--resources $AWS_PUBLIC_SUBNET \
--tags Key=Name,Value=$public_name

# create a private subnet
AWS_PRIVATE_SUBNET=$(aws ec2 create-subnet \
--vpc-id $AWS_VPC \
--cidr-block 10.0.2.0/24 \
--availability-zone $avail_zone \
--query 'Subnet.{SubnetId:SubnetId}' \
--output text)

# Add a name tag to the private subnet
read -p "Bitte gebe dem privaten Sub namen ein: " private_name
aws ec2 create-tags \
--resources $AWS_PRIVATE_SUBNET \
--tags Key=Name,Value= $private_name

# Enable auto-assign public IP on the public subnet
aws ec2 modify-subnet-attribute \
--subnet-id $AWS_PUBLIC_SUBNET \
--map-public-ip-on-launch

AWS_INTERNET_GATEWAY=$(aws ec2 create-internet-gateway \
--query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
--output text)

# Add a name tag to the Internet Gateway
read -p "Bitte gebe den namen deines Internet Gateway ein: " i_gateway
aws ec2 create-tags \
--resources $AWS_INTERNET_GATEWAY \
--tags Key=Name,Value=$i_gateway

# Get Elastic IP
AWS_ELASTIC_IP=$(aws ec2 allocate-address \
--domain vpc \
--query 'AllocationId' \
--output text)

# Create a NAT gateway
read -p "Bitte gebe die ElasticIP-ID ein (Dies findet man in der Managementconsole => EC2) " EIP_ID
AWS_NAT_GATEWAY=$(aws ec2 create-nat-gateway \
--subnet-id $AWS_PUBLIC_SUBNET \
--allocation-id $EIP_ID \
--query 'NatGateway.{NatGatewayId:NatGatewayId}' \
--output text)

# Add a name tag to the NAT gateway
read -p "Bitte gebe ein namen für den Nat Gatway ein: " nat_gateway
aws ec2 create-tags \
--resources $AWS_NAT_GATEWAY \
--tags Key=Name,Value=$nat_gateway

# Attach the Internet gateway to your VPC
aws ec2 attach-internet-gateway \
--vpc-id $AWS_VPC \
--internet-gateway-id $AWS_INTERNET_GATEWAY \
--query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
--output text

# Create a custom route table
AWS_ROUTE_TABLE=$(aws ec2 create-route-table \
--vpc-id $AWS_VPC \
--query 'RouteTable.{RouteTableId:RouteTableId}' \
--output text)

# Add a name tag to the route table
read -p "Bitte gebe den Namen der Routingtabelle ein: " route
aws ec2 create-tags \
--resources $AWS_ROUTE_TABLE \
--tags Key=Name,Value=$route

# Create a custom route table association
aws ec2 associate-route-table \
--route-table-id $AWS_ROUTE_TABLE \
--subnet-id $AWS_PUBLIC_SUBNET \
--output text

# Associate the subnet with route table, making it a public subnet
aws ec2 create-route \
--route-table-id $AWS_ROUTE_TABLE \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $AWS_INTERNET_GATEWAY \
--output text

# Associate the NAT gateway with the route table, making it a private subnet
aws ec2 create-route \
--route-table-id $AWS_ROUTE_TABLE \
--destination-cidr-block 10.2.0.0/24 \
--nat-gateway-id $AWS_NAT_GATEWAY \
--output text

# Create a security group
AWS_SECURITY_GROUP=$(aws ec2 create-security-group \
--group-name DevOpsSG \
--description "DevOps Security Group" \
--vpc-id $AWS_VPC \
--query 'GroupId' \
--output text)

# Add a name tag to the security group
read -p "Bitte gebe einen namen für die SG ein: " sg
aws ec2 create-tags \
--resources $AWS_SECURITY_GROUP \
--tags Key=Name,Value=$sg

# Add a rule to the security group

# Add SSH rule
aws ec2 authorize-security-group-ingress \
--group-id $AWS_SECURITY_GROUP \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0 \
--output text

# Add HTTP rule
aws ec2 authorize-security-group-ingress \
--group-id $AWS_SECURITY_GROUP \
--protocol tcp \
--port 80 \
--cidr 0.0.0.0/0 \
--output text

# Get the latest AMI ID
AWS_AMI=$(aws ec2 describe-images \
--owners 'amazon' \
--filters 'Name=name,Values=amzn2-ami-hvm-2.0.20221004.0-x86_64-gp2' \
'Name=state,Values=available' \
--query 'sort_by(Images, &CreationDate)[-1].[ImageId]' \
--output 'text')

# Create a key pair
read -p "Bitte gebe den namen für dein Sicherheits key ein (Bitte mit der endung .pem): " SKP
aws ec2 create-key-pair \
--key-name DevOpsKeyPair \
--query 'KeyMaterial' \
--output text > $SKP

# Change the permission of the key pair
chmod 400 $SKP


# Create a bash script to update packages, install git and clone the repo, and run the script
cat <<EOF > install.sh
#!/bin/bash

# Update packages
sudo yum update -y

# Install git
sudo yum install git -y

# Clone the repo
git clone https://github.com/MKAbuMattar/install-and-setup-wordpress-on-amazon-linux-2.git

# Run the script
bash install-and-setup-wordpress-on-amazon-linux-2/script.sh mkabumattar 121612 121612 wordpressdb wordpressuser password
EOF


# Create an EC2 instance
AWS_EC2_INSTANCE=$(aws ec2 run-instances \
--image-id $AWS_AMI \
--instance-type t2.micro \
--key-name DevOpsKeyPair \
--monitoring "Enabled=false" \
--security-group-ids $AWS_SECURITY_GROUP \
--subnet-id $AWS_PUBLIC_SUBNET \
--user-data file://install.sh \
--private-ip-address 10.0.1.10 \
--query 'Instances[0].InstanceId' \
--output text)

# Add a name tag to the EC2 instance
read -p "Bitte gebe einen Namen der Instant ein: " i_name
aws ec2 create-tags \
--resources $AWS_EC2_INSTANCE \
--tags "Key=Name,Value=$i_name"

# Get the public ip address of your instance
AWS_PUBLIC_IP=$(aws ec2 describe-instances \
--instance-ids $AWS_EC2_INSTANCE \
--query 'Reservations[*].Instances[*].[PublicIpAddress]' \
--output text)

# SSH into the EC2 instance
ssh -i DevOpsKeyPair.pem ec2-user@$AWS_PUBLIC_IP