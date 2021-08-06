#!/bin/bash

# Extract variables from config
CONFIG=dwh.cfg

AWS_ACCESS_KEY_ID=$(awk -F "=" '/^\[AWS\]/{f=1} f==1&&/^AWS_ACCESS_KEY_ID/{print $2;exit}' "${CONFIG}")
AWS_SECRET_ACCESS_KEY=$(awk -F "=" '/^\[AWS\]/{f=1} f==1&&/^AWS_SECRET_ACCESS_KEY/{print $2;exit}' "${CONFIG}")

DWH_DB=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_DB/{print $2;exit}' "${CONFIG}")
DWH_DB_USER=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_DB_USER/{print $2;exit}' "${CONFIG}")
DWH_DB_PASSWORD=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_DB_PASSWORD/{print $2;exit}' "${CONFIG}")
DWH_PORT=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_PORT/{print $2;exit}' "${CONFIG}")

echo "Creating aws_credentials connection with airflow..."
airflow connections --add --conn_id 'aws_credentials' --conn_type 'Amazon Web Services' --conn_login $AWS_ACCESS_KEY_ID --conn_password $AWS_SECRET_ACCESS_KEY

# add airflow connection -- redshift
echo "Creating redshift connection with airflow..."

airflow connections --add --conn_id 'redshift' --conn_type 'postgres' --conn_host $redshift_endpoint --conn_schema $DWH_DB --conn_login $DWH_DB_USER --conn_password $DWH_DB_PASSWORD --conn_port $DWH_PORT
