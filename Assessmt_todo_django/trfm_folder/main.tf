# Create security groups
resource "aws_security_group" "master_SG" {
    name_prefix = "master_SG"

    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "node1_SG" {
    name_prefix = "node1_SG"

    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

# create EC2 Instance
resource "aws_instance" "ans_node1" {
    ami       = var.ami
    instance_type = "t2.micro"
    #subnet_id = 
    vpc_security_group_ids = [aws_security_group.node1_SG.id]
    key_name = "ola-keypair.pem"

    tags = {
      Name = "my_assessmt_ans_node1"
    }
  
}

resource "aws_instance" "ans_node2" {
    ami       = var.ami
    instance_type = "t2.micro"
    #subnet_id = 
    vpc_security_group_ids = [aws_security_group.node1_SG.id]
    key_name = "ola-keypair.pem"

    tags = {
      Name = "my_assessmt_ans_node2"
    }
  
}