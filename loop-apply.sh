#!/usr/bin/env sh

set -e

export TF_IN_AUTOMATION=true

cd /app/terraform

while true; do
    echo "[$(date)] Initializing Terraform..."

    # Try a normal init, then fall back to -reconfigure and -upgrade if needed
    if terraform init -input=false; then
        echo "[$(date)] terraform init completed successfully"
    else
        echo "[$(date)] terraform init failed; trying -reconfigure..."
        if terraform init -input=false -reconfigure; then
            echo "[$(date)] terraform init -reconfigure succeeded"
        else
            echo "[$(date)] terraform init -reconfigure failed; trying -upgrade..."
            if terraform init -input=false -upgrade; then
                echo "[$(date)] terraform init -upgrade succeeded"
            else
                echo "[$(date)] terraform init failed; retrying in 60 seconds..."
                sleep 60
                continue
            fi
        fi
    fi

    echo "[$(date)] Attempting terraform apply..."

    if terraform apply -auto-approve; then
        echo "[$(date)] Instance created successfully!"
        exit 0
    else
        echo "[$(date)] Terraform apply failed; retrying in 60 seconds..."
        sleep 60
    fi
done
