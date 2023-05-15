# Get instance IP address
output "instance-ec2-s3-IP" {
  description = "IP of app server"
  value = aws_instance.wordpressserverlinux2.public_ip
  
}

# get Elastic IP
output "EIP_VPC" {
  value = aws_eip.elasticIP_vpc.public_ip

}