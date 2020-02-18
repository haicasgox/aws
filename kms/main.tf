################################################
#      Key Management Service (KMS)            #                                       
################################################

provider "aws" {
  region = "ap-southeast-1"
}
data "template_file" "kms" {
    template = "${file("./kms/kms_policy.json.tpl")}"
}

resource "aws_kms_key" "new_kms_key" {
    description = "new KMS key for data encryption"
    enable_key_rotation = true  //Automatically rotate this CMK (customer master key) every year. 
    policy = "${data.template_file.kms.rendered}" 
    tags = {
        Name = "new_kms_key"
    }
}

//Define the name of KMS using KMS ID
resource "aws_kms_alias" "kms_alias" {
    target_key_id  = "${aws_kms_key.new_kms_key.key_id}"
    name = "alias/demo_key"
}


