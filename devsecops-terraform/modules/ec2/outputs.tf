output "public_ip" {
  description = "Public IP of EC2 instance launched via AWS CLI"
  value       = data.external.ec2_info.result["public_ip"]
}

output "instance_id" {
  description = "Instance ID of EC2 instance launched via AWS CLI"
  value       = data.external.ec2_info.result["instance_id"]
}