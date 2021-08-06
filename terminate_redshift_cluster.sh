#!/bin/bash

# Extract variables from config
CONFIG=dwh.cfg
DWH_CLUSTER_IDENTIFIER=$(awk -F "=" '/^\[DWH\]/{f=1} f==1&&/^DWH_CLUSTER_IDENTIFIER/{print $2;exit}' "${CONFIG}")

echo "Deleting Redshift cluster"
cluster_response=$(aws redshift delete-cluster --cluster-identifier $DWH_CLUSTER_IDENTIFIER --skip-final-cluster-snapshot)
