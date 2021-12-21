# ---------------------- allowed ports --------------------------------------
locals {
  master_start = [22, 2379, 6443, 10248, 10257, 10259] # from_ports
  master_end   = [22, 2380, 6443, 10250, 10257, 10259] # to_ports
}

locals {
  worker_start = [22, 10250, 30000] # from_ports
  worker_end   = [22, 10250, 32767] # to_ports
} 

# ----------- Security group resources ---------------------------------------

resource "aws_security_group" "master" {
  name = "k8s master Security Group"

  vpc_id = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = local.master_start
    content {
      from_port   = ingress.value
      to_port     = element(local.master_end, index(local.master_start,ingress.value))
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { 
    Name = "Master SecurityGroup" 
  }

}

resource "aws_security_group" "worker" {
  name = "k8s worker Security Group"

  vpc_id = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = local.worker_start
    content {
      from_port   = ingress.value
      to_port     = element(local.worker_end, index(local.worker_start,ingress.value))
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  { 
    Name = "Worker SecurityGroup" 
  }
}
