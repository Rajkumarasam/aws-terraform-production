# 1. Security Group for Public Access (SSH)
resource "aws_security_group" "public_sg" {
  name        = "ecommerce-public-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  # Inbound Rule: Allow SSH (Port 22) from ANYWHERE (For now)
  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In a real job, restrict this to your Company VPN IP!
  }

  # Outbound Rule: Allow all traffic out (so server can download updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-public-sg"
  }
}

# 2. Security Group for Web Traffic (HTTP/HTTPS)
resource "aws_security_group" "web_sg" {
  name        = "ecommerce-web-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins from Internet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-web-sg"
  }
}
