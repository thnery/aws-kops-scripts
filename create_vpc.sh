#!/bin/bash

set -e

VPC=$1
REGION=$2
ZONE_A="a"
ZONE_B="b"

if [ -z "$VPC" ]; then
	echo "VPC Name cannot be empty!!!"
	return 0
fi

if [ -z "$REGION" ]; then
	echo "REGION cannot be empty!!!"
	return 0
fi

echo "> Creating VPC"
VPCID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 | jq -r '.Vpc.VpcId')
aws ec2 create-tags --resources $VPCID --tags Key=Name,Value=$VPC
aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-support "{\"Value\":true}"
aws ec2 modify-vpc-attribute --vpc-id $VPCID --enable-dns-hostnames "{\"Value\":true}"

echo "> Creating Internet Gateway"
IGW=$(aws ec2 create-internet-gateway | jq -r '.InternetGateway.InternetGatewayId')

echo "> Attaching Internet Gateway to VPC"
aws ec2 attach-internet-gateway --vpc-id $VPCID --internet-gateway-id $IGW

echo "> Creating Hosted Zone"
ID=$(uuidgen)
export HOSTZONEID=$(aws route53 create-hosted-zone --name $VPC --vpc "VPCRegion=$REGION,VPCId=$VPCID" --caller-reference $ID --hosted-zone-config PrivateZone=true --hosted-zone-config Comment="$VPC" | jq -r '.HostedZone.Id' | cut -d '/' -f 3)

echo "> Creating Subnets"
aws ec2 create-subnet --vpc-id $VPCID --cidr-block 10.0.100.0/24 --availability-zone $REGION$ZONE_A
aws ec2 create-subnet --vpc-id $VPCID --cidr-block 10.0.101.0/24 --availability-zone $REGION$ZONE_B

export VPCID=$VPCID
export IGW=$IGW
export HOSTZONEID=$HOSTZONEID

echo "> Summary"
echo ">> VPC Id: $VPCID"
echo ">> VPC Name: $VPC"
echo ">> Internet Gateway: $IGW"
echo ">> Hosted Zone: $HOSTZONEID"
