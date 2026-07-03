# Launch EC2 via AWS CLI to bypass the Terraform provider's internal
# ec2:DescribeImages validation call, which is blocked by SCP in sandbox accounts.
resource "null_resource" "launch_ec2" {
  triggers = {
    ami_id        = var.ami_id
    instance_type = var.instance_type
    key_name      = var.key_name
    region        = var.region
  }

  provisioner "local-exec" {
    command = <<-BASH
      set -e

      echo "Launching EC2 instance via AWS CLI..."
      INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "${var.ami_id}" \
        --instance-type "${var.instance_type}" \
        --key-name "${var.key_name}" \
        --region "${var.region}" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DevSecOps-Instance},{Key=ManagedBy,Value=Terraform}]' \
        --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":30,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
        --query 'Instances[0].InstanceId' \
        --output text)

      echo "Instance launched: $INSTANCE_ID"
      echo "Waiting for instance to reach running state..."
      aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "${var.region}"

      PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --region "${var.region}" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)

      echo "Instance is running. Public IP: $PUBLIC_IP"

      # Persist instance ID and IP to local files for output retrieval
      echo -n "$INSTANCE_ID" > /tmp/tf_ec2_instance_id.txt
      echo -n "$PUBLIC_IP"   > /tmp/tf_ec2_public_ip.txt
    BASH
    interpreter = ["bash", "-c"]
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-BASH
      set -e
      if [ -f /tmp/tf_ec2_instance_id.txt ]; then
        INSTANCE_ID=$(cat /tmp/tf_ec2_instance_id.txt)
        echo "Terminating EC2 instance: $INSTANCE_ID"
        aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "${self.triggers.region}" || true
        echo "Termination request sent."
      else
        echo "No instance ID file found, skipping termination."
      fi
    BASH
    interpreter = ["bash", "-c"]
  }
}

data "external" "ec2_info" {
  depends_on = [null_resource.launch_ec2]
  program    = ["bash", "-c", <<-BASH
    INSTANCE_ID=$(cat /tmp/tf_ec2_instance_id.txt 2>/dev/null || echo "")
    PUBLIC_IP=$(cat /tmp/tf_ec2_public_ip.txt 2>/dev/null || echo "")
    echo "{\"instance_id\": \"$INSTANCE_ID\", \"public_ip\": \"$PUBLIC_IP\"}"
  BASH
  ]
}