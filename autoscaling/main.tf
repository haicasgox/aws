################################################
#          Autoscaling (ASG)                   #                                       
################################################

provider "aws" {
  region = "ap-southeast-1"
}
//Create launch configuration for new EC2 instances
data "template_file" "userdata" {
  template = "${file("./autoscaling/userdata.tpl")}"
}
resource "aws_launch_configuration" "launch_configuration" {
    name = "Feb2020launch_configuration"
    image_id ="ami-05c64f7b4062b0a21"
    instance_type = "t2.micro"
    key_name = "public_key_Feb2020"
    security_groups = ["${var.asg_security_group}"]
    user_data = "${data.template_file.userdata.rendered}"
    lifecycle{
        create_before_destroy = true   //Value "true" to ask Terraform to always create a replacement resource before destroying the original resource. 
                                       //"Create_before_destroy is "true" on any resource, then it should be "true" on the dependency resources.
    }    
}
//Create ASG
//data "aws_availability_zone" "available" {
    //state = "available"
//}
resource "aws_autoscaling_group" "ASGFeb2020" {
    name = "ASGFeb2020"
    launch_configuration = "${aws_launch_configuration.launch_configuration.name}"
    vpc_zone_identifier = "${var.subnet_id}"  //A list of subnet id to launch resources in.
    //availability_zones = ["${data.aws_availability_zone.available.name}"] // Ensure instances will be deployed in different AZ.
    target_group_arns = ["${var.target_group_arn}"]
    health_check_type = "EC2" // This value can be "EC2" or "ELB" to control the health checking.
    health_check_grace_period = 300
    force_delete = true
    min_size = 2  //Define minimum and maximum number of the instance in ASG
    max_size = 6
    tag {
        key = "Name"
        value =  "ASGFeb2020"
        propagate_at_launch = true
    }
}
//Define scaling up policy
resource "aws_autoscaling_policy" "scale_up" {
    name = "scale_up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    policy_type = "SimpleScaling"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.ASGFeb2020.name}"
}
// Define scaling down policy 
resource "aws_autoscaling_policy" "scale_down" {
    name = "scale_down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    policy_type = "SimpleScaling"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.ASGFeb2020.name}"  
}
//Define Cloudwatch Alarm to trigger ASG --> scaling up policy
resource "aws_cloudwatch_metric_alarm" "cpu_high_utilization" {
  alarm_name = "cpu_high_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "80"
  alarm_description = "This metric monitors EC2 CPU high usage"
  alarm_actions = [
      "${aws_autoscaling_policy.scale_up.arn}",
      "${var.sns_topic}"
  ]
  dimensions = {
      AutoScalingGroupName = "${aws_autoscaling_group.ASGFeb2020.name}"
  }
}
//Define Cloudwatch Alarm to trigger ASG --> scaling down policy
resource "aws_cloudwatch_metric_alarm" "cpu_low_utilization" {
    alarm_name = "cpu_low_utilization"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "1"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "30"
    alarm_description = "This metric monitors EC2 CPU normal usage"
    alarm_actions = [
        "${aws_autoscaling_policy.scale_down.arn}",
        "${var.sns_topic}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.ASGFeb2020.name}"
    }   
}







