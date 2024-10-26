provider "aws" {
  region = "us-east-1" # replace with your region
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-1324"
    # key            = "path/to/terraform.tfstate"  # path within the S3 bucket to store the state file
    region         = "us-east-1"  # replace with your AWS region
    # encrypt        = true         # enable server-side encryption (recommended)
    # dynamodb_table = "your-lock-table"  # optional, for state locking
  }
}

data "aws_ami" "latest" {     # aws_ami helps to get AMI ID of the os
    most_recent = true  # this is the filter for most recent Ami
   
    filter {   # this is the filter for virtualization type
      name = "virtualization-type"
      values = ["hvm"]
    }
    filter {  # this is the filter for AMI name of the OS which can be found in AMI section in EC2
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
     owners = ["099720109477"]  # this is the owner of the OS, which can be found in AMI section in EC2
}


resource "aws_instance" "jenkins-server" {   # we are creating a new instance for jenkins-server
    ami = data.aws_ami.latest.id    # we are using the latest ami that we fetched earlier
    instance_type = "t3.medium"     # This is the type of the instance we are creating
    # subnet_id = aws_subnet.our-public-subnet.id   # this is the id of the subnet we are using to launch the instance
    user_data = file("./mern.sh")  # this is the script that will be executed during the creation of the instance
    key_name = "mern-stack" # this is the key name that we have created in console
    root_block_device {
      volume_size = 20
    }

    tags = {
        Name = "jenkins-server"  # this will provide name to instance 
    }
}
