resource "aws_security_group" "sg_spark_terraform" {
  name        = "sg_spark_terraform"
  description = "Spark provisioned from Terraform"
  vpc_id      = "${local.vpc_id}"

  /*ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${local.cidr_blocks}"]
    self        = "true"
  }*/

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.cidr_blocks}"]
    description = "ssh"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
