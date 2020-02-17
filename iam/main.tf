provider "aws" {
    region = "ap-southeast-1"
}
//Part 1: Create new users in IAM
resource "aws_iam_user" "iamuser" {
  count = "${length(var.username)}"
  name = "${element(var.username, count.index)}"
}
//Refer to data source of IAM
data "aws_iam_policy_document" "iampolicy" {
    statement {
        actions = [
            "ec2:*"
        ]
        resources = [
             "*"
        ]
    } 
}
//Define IAM policy of EC2 full permission
resource "aws_iam_policy" "iampolicy" {
    name = "ec2-full-permission"
    policy = "${data.aws_iam_policy_document.iampolicy.json}"
}
//Attach the IAM policy to the recently created users
resource "aws_iam_user_policy_attachment" "iampolicyattachment" {
    count = "${length(var.username)}"
    user = "${element(aws_iam_user.iamuser.*.name, count.index)}"
    policy_arn  = "${aws_iam_policy.iampolicy.arn}" 
}
//Part 2: Create a IAM role
resource "aws_iam_role" "iam_role" {
    name = "iam_role"
    assume_role_policy = <<EOF
    { 
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
            "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    } 
    EOF
    tags = {
        tag-key = "tag-value"
    }
  
}
//Create EC2 instance profile
resource "aws_iam_instance_profile" "instance_profile" {
    name = "instance_profile"
    role = "${aws_iam_role.iam_role.name}"
}
//Define a IAM for S3 policy
data "aws_iam_policy_document" "S3policy" {
    statement {
        actions = [
            "s3:*",
        ]
        resources = [
            "*",
        ]
    }
}
//Add the policy (access to S3) to IAM role 
resource "aws_iam_role_policy" "S3_policy" {
    name = "S3_policy"
    role = "${aws_iam_role.iam_role.id}"
    policy = "${data.aws_iam_policy_document.S3policy.json}"
}
//Attach the role to EC2 instance
/*data "aws_ami" "ubuntu" {
    most_recent = true
    executable_users = ["self"]
    owners = ["self"]
    
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-arm64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}*/
resource "aws_key_pair""EC2_key_pair"{
    key_name = "EC2_key_pair"
    public_key = "${var.EC2_public_key}"
}
resource "aws_instance" "EC2_role_attachment" {
  ami = "ami-09a4a9ce71ff3f20b"    /*ami =  "${data.aws_ami.ubuntu.id}"*/
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  key_name = "EC2_key_pair"
  tags = {
      Name = "IAM_Role_To_S3"
  }
}