################################################
#      Relational Database Service (RDS)       #                                       
################################################

provider "aws" {
    region = "ap-southeast-1" 
}
//Create RDS instance
resource "aws_db_instance" "DB_instance" {
    instance_class = "${var.db_instance}"
    engine = "${var.db_engine}"
    engine_version = "8.0.16"
    multi_az = true
    storage_type = "gp2"
    allocated_storage = 20
    name = "DB_instance"
    username = "admin"
    password = "DBAWS@dmin2020"
    apply_immediately = "true"
    backup_retention_period = 10 
    backup_window = "15:00-17:00"
    db_subnet_group_name = "${aws_db_subnet_group.db_subnet_group.name}" //DB instance will be created in the VPC associated with the DB subnet group. 
    vpc_security_group_ids = ["${aws_security_group.db_security_group.id}"] //List of security group to associate
    skip_final_snapshot = true //Determine whether final DB snapshot is created before DB instance is deleted or not. Default value is "false", meaning that DB snapshot will be created.
}
//Create subnet groups 
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "db_subnet_group"
  subnet_ids = ["${var.rds_subnet1}","${var.rds_subnet2}"]
}
//Create security groups adn inbound and outbound rules
resource "aws_security_group" "db_security_group" {
    name = "db_security_group"
    vpc_id = "${var.vpc_id}"
    
    //Inbound rules
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    //Outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}