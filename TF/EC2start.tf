# Describe Instance
data "aws_instances" "filtered" {
  filter {
    name   = "tag:Name"
    values = ["PortFolio"] # Instance Name
  }
}

# Start EC2
resource "null_resource" "start_ec2" {
  count = length(data.aws_instances.filtered.ids)

  provisioner "local-exec" {
    command = "aws ec2 start-instances --instance-ids ${data.aws_instances.filtered.ids[count.index]}"
  }
}