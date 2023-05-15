variable "ami" {
    default = "ami-0a695f0d95cefc163"
    description = "ubuntu AMI"
  
}

variable "subnet_assmt_pub" {
    type = list(string)
    default = ["subnet-017b912d593d1de5b" , "subnet-095b6e69f2e8d13a7"]
  
}

variable "vpc_id" {
    type = string
    default = "vpc-04b83f94794021510"
  
}