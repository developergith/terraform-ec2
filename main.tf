provider "aws" {
  region = "ap-south-1"
}

 
resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = file("my-key.pub")
}

 
resource "aws_security_group" "ec2_sg" {
  name = "ec2-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

 
resource "aws_instance" "my_ec2" {
  ami           = "ami-0e12ffc2dd465f6e4"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.ec2_sg.name]
 
   root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

   
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "Terraform-Full-EC2"
  }
}