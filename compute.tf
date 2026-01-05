# 1. Get the latest Ubuntu AMI dynamically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner] # Canonical (Official Ubuntu Owner)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Upload your SSH Public Key to the NEW AWS Account
resource "aws_key_pair" "deployer" {
  key_name   = "ecommerce-key"
  public_key = file("~/.ssh/ecommerce-key.pub")
}

# 3. Create the EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type # Free Tier
  subnet_id     = aws_subnet.public.id

  # Attach the Security Groups (The Locks)
  vpc_security_group_ids = [
    aws_security_group.public_sg.id,
    aws_security_group.web_sg.id
  ]

  key_name = aws_key_pair.deployer.key_name

  # User Data: This script runs automatically when the server turns on
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              echo "<h1>Recovery Successful: E-Commerce Server is Live</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "ecommerce-bastion"
  }
}

# 4. Output the Public IP so we can access it
output "server_public_ip" {
  value = aws_instance.web_server.public_ip
}
