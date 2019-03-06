# AWS Kops Scripts

  This repository contains scripts to automate VPC and Cluster creation on AWS and also 
create mandatory Kubernetes resources for running a production application.

## Requirements
  
  * JQ `brew install jq` or `pip install jq`

## How-to

  The steps below will create the VPC and the Cluster.

1. Run script `001_create_vpc.sh`
2. Run script `002_create_cluster.sh`

## Examples:
### Create VPC
  This will create the VPC on AWS. The required params are the VPC name and the desired ZONE.

`$ ./001_create_vpc.sh demo.vpc us-east-1`

### Create Cluster
  This will create the cluster within the VPC. The required params are the cluster name, the desired ZONE,
the Nodes instance type, the Master instance type, the VPC ID (returned by previous script) and the Hosted Zone ID, this
one you can get on Route53 on AWS Dashboard.

`$ ./002_create_cluster cluster.demo.vpc us-east-1b t2.small t2.medium MYVPCID MYHOSTEDZONEID`


## TO-DO
  * Security Groups creation
  * Subnet Groupts creation
  * RDS Instance creation
  * Elasticache creation
