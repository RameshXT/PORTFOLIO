# SG
data "aws_security_group" "existing" {
  filter {
    name   = "group-name"
    values = ["Primary-SG"]
  }
}

# EC2
resource "aws_instance" "my_ec2" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t3.medium"

  vpc_security_group_ids = [data.aws_security_group.existing.id]
  key_name        = "Primary-KEY"

  tags = {
    Name = "PortFolio"
  }
}
