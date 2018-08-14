#!/usr/bin/env bash

set -e

NAME=$1
ZONES=$2
NODE_SIZE=$3
MASTER_SIZE=$4
VPCID=$5
HOSTZONEID=$6

if [ -z "$NAME" ]; then
	echo "!!! Cluster Name cannot be empty !!!"
	return 0
fi

if [ -z "$ZONES" ]; then
	echo "!!! Zones cannot be empty !!!"
	return 0
fi

if [ -z "$NODE_SIZE" ]; then
	echo "!!! Nodes Size cannot be empty !!!"
	return 0
fi

if [ -z "$MASTER_SIZE" ]; then
	echo "!!! Master Size cannot be empty !!!"
	return 0
fi

export NAME=$NAME
export KOPS_STATE_STORE="s3://$NAME"

echo "> Creating state store"
aws s3 mb $KOPS_STATE_STORE

echo "> Creating k8s cluster with kops"
kops create cluster --zones $ZONES --name $NAME --dns private --dns-zone $HOSTZONEID --vpc $VPCID --topology private --networking kopeio-vxlan --node-size $NODE_SIZE --master-size $MASTER_SIZE

echo "> Building k8s cluster with kops"
kops update cluster $NAME --yes

echo "> Summary:"
echo ">> Name: $NAME"
echo ">> KopsStateStore: $KOPS_STATE_STORE"
