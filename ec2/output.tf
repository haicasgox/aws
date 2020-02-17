//Take out values of two instance IDs 
output "instance01_id" {
  value = "${element(aws_instance.Feb072020.*.id, 1)}"
}
output "instance02_id" {
  value = "${element(aws_instance.Feb072020.*.id, 2)}"
}
