/* Transit gateway:  connect thousands of AWS VPC and on-premises infra using a single gateway through Site-to-Site VPN connection. 
+)Using a Hub and Spoke network tech. 
+) It can scale up to 5000VPCs; spread the traffics over many VPN connections (speed up to 2.5Gbps)
+) Max throughput is ideally 50 Gbps
+) Direct Connection supports Transit Gateway (except China)
+) Route Table support 10,000 routes. 
*/
resource "aws_ec2_transit_gateway" "transit_gateway" {
  description = "transit_gateway"
  auto_accept_shared_attachments = "disable" 
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support = "enable"
  vpn_ecmp_support  = "enable"
  tags = {
      Name = "transit_gateway"
  }
}

//Attach VPC to transit gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}" 
    vpc_id = "${var.vpc_id}"
    dns_support = "enable"

    subnet_ids = [
        "${var.public_subnet1}",
        "${var.public_subnet2}",
    ]
    tags = {
        Name = "TGW_attachment"
    }
}


