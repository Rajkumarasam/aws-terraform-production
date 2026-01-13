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

# 2. Upload your SSH Public Key to AWS
resource "aws_key_pair" "deployer" {
  key_name   = "ecommerce-key"
  public_key = file("~/.ssh/ecommerce-key.pub")
}

# 3. Create the EC2 Instance (Jenkins Server)
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type # Uses t3.micro from variables.tf
  subnet_id     = aws_subnet.public.id

  # Attach the Security Groups (SSH, HTTP, HTTPS, Jenkins-8080)
  vpc_security_group_ids = [
    aws_security_group.public_sg.id,
    aws_security_group.web_sg.id
  ]

  key_name = aws_key_pair.deployer.key_name

  # ROOT DISK SIZE (Optional but recommended for Jenkins)
  root_block_device {
    volume_size = 15    # Increased to 15GB to fit Docker images
    volume_type = "gp3"
  }

  tags = {
    Name = "ecommerce-jenkins-server"
  }

  # --- AUTOMATED INSTALLATION SCRIPT ---
  # This runs once when the server boots up.
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # 1. Update System & Install Basics
    echo "--- STARTING SETUP ---"
    apt-get update
    apt-get install -y unzip fontconfig openjdk-17-jre git

    # 2. Configure Swap Space (Crucial for t3.micro stability)
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    echo "--- SWAP CONFIGURED ---"

    # 3. Install Jenkins (LTS Version)
    wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt-get update
    apt-get install -y jenkins
    systemctl start jenkins
    systemctl enable jenkins
    echo "--- JENKINS INSTALLED ---"

    # 4. Install Docker
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    # Grant Jenkins permission to run Docker
    usermod -aG docker jenkins
    usermod -aG docker ubuntu
    # Restart Jenkins to apply permissions
    systemctl restart jenkins
    echo "--- DOCKER INSTALLED ---"

    # 5. Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    echo "--- AWS CLI INSTALLED ---"

    # 6. Install Terraform (Optional utility)
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update
    apt-get install -y terraform

    echo "<h1>Jenkins Server Ready</h1>" > /var/www/html/index.html
    echo "--- SETUP COMPLETE ---"
  EOF
}

# 4. Output the Public IP
output "server_public_ip" {
  value = aws_instance.web_server.public_ip
}
