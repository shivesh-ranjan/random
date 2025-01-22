#!/bin/bash

IMAGE_NAME="Ubuntu-20.04"
FLAVOR="S.4"
NETWORK="shiveshNetwork"
SECURITY_GROUP="kube_sg"

# List of names for the volumes and VMs
declare -a VM_NAMES=("shiv" "shiv_worker1" "shiv_worker2")

# Loop through the VM_NAMES array
for VM_NAME in "${VM_NAMES[@]}"; do
    # Create a volume with the same name as the VM
    echo "Creating volume $VM_NAME"
    VOLUME_ID=$(openstack volume create --size 20 --image $IMAGE_NAME --description "Volume for $VM_NAME" $VM_NAME -f value -c id)

    if [ -z "$VOLUME_ID" ]; then
        echo "Error: Failed to create volume for $VM_NAME"
        continue
    fi

    echo "Volume $VM_NAME created with ID: $VOLUME_ID"

    # Create the VM with the same name as the volume
    echo "Creating VM $VM_NAME"
    VM_ID=$(openstack server create --flavor $FLAVOR --network $NETWORK --security-group $SECURITY_GROUP --volume $VOLUME_ID --key-name test $VM_NAME -f value -c id)

    if [ -z "$VM_ID" ]; then
        echo "Error: Failed to create VM for $VM_NAME"
        continue
    fi

    echo "VM $VM_NAME created with ID: $VM_ID"

done

echo "Script execution completed."
