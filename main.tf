provider "aws" {
    region = "ap-southeast-1"
    version = "~>2.0"
    /*shared_credentials_file = ".awscredentials/accessKeys.csv"*/
}
//This module is for VPC
module "vpc" {
    source = "./vpc"
    vpc_cidr ="172.16.0.0/16"
    public_cidrs = ["172.16.10.0/24","172.16.20.0/24"]
    private_cidrs = ["172.16.30.0/24","172.16.40.0/24"]
}
/*module "ec2" {
  //source = "./ec2"
  //public_key = ".ssh/public_key_Feb2020"
  //instance_type = "t2.micro"
  //security_group = "${module.vpc.security_group}"
  //subnets = "${module.vpc.public_subnets}"*/

//This module is for ELB
module "elb" {
  source = "./elb"
  vpc_id = "${module.vpc.vpc_id}"
  subnet01 = "${module.vpc.subnet1}"
  subnet02 = "${module.vpc.subnet2}"
  SG_ALB_Feb2020 = "${module.vpc.security_group}"
   /*instance01_id = "${module.ec2.instance01_id}"
  instance02_id = "${module.ec2.instance02_id}" */
}
//This module is for ASG
module "autoscaling" {
  source = "./autoscaling"
  asg_security_group = "${module.vpc.security_group}"
  subnet_id = "${module.vpc.public_subnets}"
  target_group_arn = "${module.elb.elb_target_group_arn}"  
  sns_topic = "${module.sns.sns_arn}"
}
//This module is for SNS
module "sns" {
  source = "./sns"
  alarms_email = "jalanosvn@gmail.com"
}
//This module is for DB
module "db" {
  source = "./rds"
  db_engine = "mysql"
  db_instance = "db.t2.micro"
  vpc_id = "${module.vpc.vpc_id}"
  rds_subnet1 = "${module.vpc.private_subnet1}"
  rds_subnet2 = "${module.vpc.private_subnet2}"
}
//This module is for IAM
module "iam" {
  source = "./iam"
  username = ["user1","user2"]
  EC2_public_key = ".ssh/public_key_Feb2020"  
}
