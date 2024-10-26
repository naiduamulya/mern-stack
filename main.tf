provider "aws" {
  region = "us-east-1" # replace with your region
}

resource "aws_key_pair" "deploy_key" {
  key_name   = "deploy_key"
  public_key = file("~/.ssh/your_public_key.pub") # replace with path to your public key
}

resource "aws_instance" "mern_instance" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (or a compatible one)
  instance_type          = "t2.micro"              # use appropriate instance type
  key_name               = aws_key_pair.deploy_key.key_name
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    # Update packages
    sudo yum update -y
    # Install Node.js
    curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
    sudo yum install -y nodejs
    # Install MongoDB
    sudo tee /etc/yum.repos.d/mongodb-org-4.4.repo <<EOF2
    [mongodb-org-4.4]
    name=MongoDB Repository
    baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.4/x86_64/
    gpgcheck=1
    enabled=1
    gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
    EOF2
    sudo yum install -y mongodb-org
    sudo systemctl start mongod
    sudo systemctl enable mongod
    # Install PM2
    sudo npm install -g pm2
    # Create app directory
    sudo mkdir -p /var/www/html
    sudo chown ec2-user:ec2-user /var/www/html
  EOF

  tags = {
    Name = "mern-server"
  }
}
