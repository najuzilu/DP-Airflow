#!/bin/bash

# Extract variables from config
CONFIG=dwh.cfg

AWS_ACCESS_KEY_ID=$(awk -F "=" '/^\[AWS\]/{f=1} f==1&&/^AWS_ACCESS_KEY_ID/{print $2;exit}' "${CONFIG}")
AWS_SECRET_ACCESS_KEY=$(awk -F "=" '/^\[AWS\]/{f=1} f==1&&/^AWS_SECRET_ACCESS_KEY/{print $2;exit}' "${CONFIG}")

DWH_IAM_ROLE_NAME=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_IAM_ROLE_NAME/{print $2;exit}' "${CONFIG}")
DWH_CLUSTER_TYPE=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_CLUSTER_TYPE/{print $2;exit}' "${CONFIG}")
DWH_NODE_TYPE=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_NODE_TYPE/{print $2;exit}' "${CONFIG}")
DWH_NUM_NODES=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_NUM_NODES/{print $2;exit}' "${CONFIG}")
DWH_DB=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_DB/{print $2;exit}' "${CONFIG}")
DWH_CLUSTER_IDENTIFIER=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_CLUSTER_IDENTIFIER/{print $2;exit}' "${CONFIG}")
DWH_DB_USER=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_DB_USER/{print $2;exit}' "${CONFIG}")
DWH_DB_PASSWORD=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_DB_PASSWORD/{print $2;exit}' "${CONFIG}")
DWH_POLICY_ARN=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_POLICY_ARN/{print $2;exit}' "${CONFIG}")
DWH_PORT=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_PORT/{print $2;exit}' "${CONFIG}")

USERNAME=$(awk -F "=" '/^\[AIRFLOW\]/{f=1} f==1&&/^USERNAME/{print $2;exit}' "${CONFIG}")
EMAIL=$(awk -F "=" '/^\[AIRFLOW\]/{f=1} f==1&&/^EMAIL/{print $2;exit}' "${CONFIG}")
FIRST_NAME=$(awk -F "=" '/^\[AIRFLOW\]/{f=1} f==1&&/^FIRST_NAME/{print $2;exit}' "${CONFIG}")
LAST_NAME=$(awk -F "=" '/^\[AIRFLOW\]/{f=1} f==1&&/^LAST_NAME/{print $2;exit}' "${CONFIG}")
PASSWORD=$(awk -F "=" '/^\[AIRFLOW\]/{f=1} f==1&&/^PASSWORD/{print $2;exit}' "${CONFIG}")

IP=$(awk -F "=" '/^\[WORKSTATION\]/{f=1} f==1&&/^IP/{print $2;exit}' "${CONFIG}")

# get vpc security group ID
echo "Retrieving VpcSecurityGroupId..."
vpc_sg_id=$(aws redshift describe-clusters --cluster-identifier $DWH_CLUSTER_IDENTIFIER --query "Clusters[*].VpcSecurityGroups[*].VpcSecurityGroupId | [0][0]" --output text)

# get old cidr
echo "Getting security group CIDR..."
old_cidr=$(aws ec2 describe-security-groups --group-ids $vpc_sg_id --filters Name=ip-permission.from-port,Values=$DWH_PORT Name=ip-permission.protocol,Values=tcp --query "SecurityGroups[*].IpPermissions[*] | [0][0].IpRanges[*].CidrIp | [0]" --output text)

# revoke old rule
echo "Authorizing inbound security rule for IP ${IP}"
aws ec2 revoke-security-group-ingress --group-id $vpc_sg_id --protocol tcp --port $DWH_PORT --cidr $IP/32 --cidr $old_cidr

# Authorize inbound security rule from current IP address
echo "Authorizing inbound security rule from current IP address..."
aws ec2 authorize-security-group-ingress --group-id $vpc_sg_id --protocol tcp --port $DWH_PORT --cidr $IP/32

# retrieve redshift endpoint
echo "Retrieving redshift endpoint..."
redshift_endpoint=$(aws redshift describe-clusters --cluster-identifier $DWH_CLUSTER_IDENTIFIER --query "Clusters[*].Endpoint.Address | [0]" --output text)
echo "Redshift cluster endpoint is ${redshift_endpoint}"
echo -e "**********************************************\n"
echo "export redshift_endpoint=${redshift_endpoint}"
echo -e "**********************************************\n"
export redshift_endpoint

#### _create file: unittests.cfg_
#### cluster_response=$(aws redshift delete-cluster --cluster-identifier $DWH_CLUSTER_IDENTIFIER --skip-final-cluster-snapshot)
#### cluster_status=$(aws redshift describe-clusters --cluster-identifier $DWH_CLUSTER_IDENTIFIER --query "Clusters[*].ClusterStatus | [0]" --output text)
####
####
#### find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
#### IP=$(curl -s http://whatismyip.akamai.com/)
