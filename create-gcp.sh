#!/bin/sh

# Use the `gcloud init --console-only` command to login to the current gcloud

GLOBAL_TAG="cloud-computing"

### Specify ssh key configuration
SSH_USER_NAME="myuser"
SSH_USER_ID_PATH="id_rsa"
SSH_USER_ID_GCE_PATH="/tmp/id_gce_rsa"

# Generate the SSH key and copy pub file to a "gcloud pub format"; it is formatted as necessary for the GCE platform
ssh-keygen -N "" -C "$SSH_USER_NAME" -f "$SSH_USER_ID_PATH"
echo "$SSH_USER_NAME"':'"$(cat "$SSH_USER_ID_PATH".pub)" > "$SSH_USER_ID_GCE_PATH"

# Upload the pub SSH key to the gcloud compute management
gcloud compute project-info add-metadata --metadata-from-file ssh-keys="$SSH_USER_ID_GCE_PATH"

# Remove the local copy for gce of the pub key
rm -f "$SSH_USER_ID_GCE_PATH"

### Create firewall rule that allows incoming ICMP and SSH traffic according to the global tag, that was specified before
gcloud compute firewall-rules create "allowsshcloudcomputing" \
    --allow=tcp:22 \
    --direction IN \
    --target-tags="$GLOBAL_TAG" \
    --description="Allows SSH traffic from everywhere to 'Cloud Computing' tagged instances"

gcloud compute firewall-rules create "allowicmpcloudcomputing" \
    --allow=icmp \
    --direction IN \
    --target-tags="$GLOBAL_TAG" \
    --description="Allows ICMP traffic from everywhere to 'Cloud Computing' tagged instances"

# To list the configured firewall rules use `gcloud compute firewall-rules list`

### Create Instance
INSTANCE_CREATE_NAME="my-test-instance"
# Zone according to `gcloud compute zones list`
INSTANCE_CREATE_ZONE="europe-west3-a"
# Machine Type according to `gcloud compute machine-types list`
INSTANCE_CREATE_TYPE="g1-small"
# Image according to `gcloud compute images list`
INSTANCE_CREATE_IMAGE="ubuntu-1804-bionic-v20191113"
INSTANCE_CREATE_IMAGE_PROJECT="ubuntu-os-cloud"
INSTANCE_CREATE_TAGS="$GLOBAL_TAG"

# Create the actual instance on GCE with the necessary configuration as indicated above
gcloud compute instances create \
    "$INSTANCE_CREATE_NAME" \
    --machine-type "$INSTANCE_CREATE_TYPE" \
    --image "$INSTANCE_CREATE_IMAGE" \
    --image-project "$INSTANCE_CREATE_IMAGE_PROJECT" \
    --zone "$INSTANCE_CREATE_ZONE" \
    --tags "$INSTANCE_CREATE_TAGS"

# To list all machines use `gcloud compute instances list`

# To delete a machine use the following command `gcloud compute instances delete --quiet "$INSTANCE_CREATE_NAME" --zone="$INSTANCE_CREATE_ZONE"`


### Use the following line to add the crontab entry for periodic benchmarking
# echo '0,30 * * * * ubuntu /var/lib/cc/benchmark.sh >> /var/lib/cc/result.csv' | sudo tee -a /etc/crontab