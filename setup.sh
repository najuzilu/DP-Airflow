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

# Check to see if role already exists

iam_role_exists=$(aws iam get-role --role-name $DWH_IAM_ROLE_NAME --query "Role.RoleName" --output text)

if [[ "${iam_role_exists}" == "${DWH_IAM_ROLE_NAME}" ]]
then
    echo -e "Iam role already exists"
elif echo $iam_role_exists | grep -q 'NoSuchEntity' -s;
then
    echo "No Such role exists. Creating Iam Role..."
    aws iam create-role --role-name $DWH_IAM_ROLE_NAME  --path "/" --assume-role-policy-document file://Role-Trust-Policy.json --description "Allows Redshift cluster to call AWS services on your behalf."

    # Attach role policy
    echo "Attaching role policy..."
    aws iam attach-role-policy --role-name $DWH_IAM_ROLE_NAME --policy-arn $DWH_POLICY_ARN
else
    echo $iam_role_exists
    exit
fi

# get role arn
echo "Extracting role arn..."
role_arn=$(aws iam get-role --role-name $DWH_IAM_ROLE_NAME --query "Role.Arn" --output text)

# create Redshift cluster on AWS
echo 'Creating Redashift cluster...'
cluster_response=$(aws redshift create-cluster --db-name $DWH_DB --cluster-identifier $DWH_CLUSTER_IDENTIFIER --cluster-type $DWH_CLUSTER_TYPE --node-type $DWH_NODE_TYPE --number-of-nodes $DWH_NUM_NODES --master-username $DWH_DB_USER --master-user-password $DWH_DB_PASSWORD --iam-roles $role_arn)

# check redshift cluster status
cluster_status=$(aws redshift describe-clusters --cluster-identifier $DWH_CLUSTER_IDENTIFIER --query "Clusters[*].ClusterStatus | [0]" --output text)
echo "Redshift cluster status is ${cluster_status}..."

while [ $cluster_status != "available" ]; do

    sleep 15
    cluster_status=$(aws redshift describe-clusters --cluster-identifier $DWH_CLUSTER_IDENTIFIER --query "Clusters[*].ClusterStatus | [0]" --output text)

done

echo -e "Update: Redshift cluster status is ${cluster_status}\n"
sleep 15

# add airflow connection -- aws
echo "Creating aws_credentials connection with airflow..."
airflow connections add 'aws_credentials' --conn-type 'Amazon Web Services' --conn-login $AWS_ACCESS_KEY_ID --conn-password $AWS_SECRET_ACCESS_KEY

# retrieve redshift endpoint
echo "Retrieving redshift endpoint..."
redshift_endpoint=$(aws redshift describe-clusters --cluster-identifier $DWH_CLUSTER_IDENTIFIER --query "Clusters[*].Endpoint.Address | [0]" --output text)

# add airflow connection -- redshift
echo "Creating redshift connection with airflow..."
airflow connections add 'redshift' --conn-type 'Postgres'  --conn-login $DWH_DB_USER --conn-password $DWH_DB_PASSWORD --conn-host $redshift_endpoint --conn-port $DWH_PORT --conn-schema $DWH_DB

# # cluster_response=$(aws redshift delete-cluster --cluster-identifier $DWH_CLUSTER_IDENTIFIER --skip-final-cluster-snapshot)


# # cluster_status=$(aws redshift describe-clusters --cluster-identifier $DWH_CLUSTER_IDENTIFIER --query "Clusters[*].ClusterStatus | [0]" --output text)
