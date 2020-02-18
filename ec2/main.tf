################################################
#      Elastic Compute Cloud (EC2)             #                                       
################################################

provider "aws" {
  region = "ap-southeast-1"
  //shared_credentials_file = ".awscredentials/accessKeys.csv"
}
//Find out the available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

//Create a keypair to ssh to the instance
resource "aws_key_pair" "EC2keypair" {
    key_name = "public_key_Feb2020"
    public_key = "${file(var.public_key)}"
}
//Define the location of userdata for the instance
data "template_file" "userdata" {
  template = "${file("./ec2/userdata.tpl")}"
}
//Create a instance
resource "aws_instance" "Feb072020" {
    count = 2
    ami = "ami-05c64f7b4062b0a21"
    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.EC2keypair.id}"
    vpc_security_group_ids = ["${var.security_group}"]
    subnet_id = "${element(var.subnets,count.index)}"
    user_data = "${data.template_file.userdata.rendered}"
    tags = {
        Name = "2020Feb07EC2"
    }
}

//Create a new EBS volume
resource "aws_ebs_volume" "ebs" {
    count = 2
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    size = 2
    type = "gp2"
    encrypted = "true"
    tags = {
        Name = "2020Feb07EBS"
    }
}
//Attaching the created volume to the instance
resource "aws_volume_attachment" "vol-attach" {
  count = 2
  device_name = "/dev/xvdh"
  instance_id = "${aws_instance.Feb072020.*.id[count.index]}"
  volume_id = "${aws_ebs_volume.ebs.*.id[count.index]}"
}
