################################################
#      Elastic Load Balancing (ELB)            #                                       
################################################

provider "aws" {
  region = "ap-southeast-1"
}

//Create a target group for ELB
resource "aws_lb_target_group" "TGFeb2020" {
  health_check {
      interval = 10
      path = "/"
      protocol =  "HTTP"
      timeout = 5
      healthy_threshold = 3 //Number of consecutive healt checkes successes required before considering the unhealthy TG healthy. 
      unhealthy_threshold = 3  //Number of consecutive health checks failures required before considering the target unhealthy.
  }
name = "TGFeb2020"
port = 80
protocol = "HTTP"
target_type = "instance" //Default type of TG, it can be instance, IP address (private IP of the subnet in VPC where TG is created) or Lambda (ARN of Lamda)
vpc_id = "${var.vpc_id}"
}

//Create a instance registration with ELB
//resource "aws_lb_target_group_attachment" "lb_TG_attachment01" {
   //target_group_arn = "${aws_lb_target_group.TGFeb2020.arn}" //ARN of the TG
   //target_id = "${var.instance01_id}" //Target ID is the instance ID 
   //port = 80 
//}
//resource "aws_lb_target_group_attachment" "lb_TG_attachment02" {
  //target_group_arn = "${aws_lb_target_group.TGFeb2020.arn}" 
  //target_id = "${var.instance02_id}"
  //port = 80
//}

//Define application load balancer
resource "aws_lb" "ALBFeb2020" {
    name = "ALBFeb2020"
    internal = false

    //Define SG being used by ALB
    security_groups = [
      "${var.SG_ALB_Feb2020}"
    ]
    //Define subnets being used by ALB
    subnets = [
        "${var.subnet01}", 
        "${var.subnet02}",
    ]
    tags = {
        Name = "ALBFeb2020"
        }
    ip_address_type = "ipv4"
    load_balancer_type = "application"
}

//Create a ALB listener resource
resource "aws_lb_listener" "ALB_Listener" {
  load_balancer_arn = "${aws_lb.ALBFeb2020.arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.TGFeb2020.arn}"
  }  
}






