resource "aws_security_group" "sg_spark_terraform" {
  name        = "sg_spark_terraform"
  description = "Spark provisioned from Terraform"
  vpc_id      = local.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = local.cidr_blocks
    self        = "true"
  }

  # ssh
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = local.cidr_blocks
    description = "ssh"
  }

  # spark master UI
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = local.cidr_blocks
    description = "spark master"
  }

  # spark worker UI
  ingress {
    from_port = 8081
    to_port   = 8081
    protocol  = "tcp"
    cidr_blocks = local.cidr_blocks
    description = "spark master"
  }

  # spark history server
  ingress {
    from_port = 18080
    to_port   = 18080
    protocol  = "tcp"
    cidr_blocks = local.cidr_blocks
    description = "spark history server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}