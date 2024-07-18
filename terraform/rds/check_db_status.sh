#!/bin/bash
db_instance_id=$1

while true; do
  status=$(aws rds describe-db-instances --db-instance-identifier $db_instance_id --query "DBInstances[0].DBInstanceStatus" --output text)
  if [ "$status" == "available" ]; then
    echo "DB instance is available."
    exit 0
  fi
  echo "Waiting for DB instance to be available..."
  sleep 30
done
