# ------------------- EC2 resources ---------------------------------

resource "aws_instance" "master" {
  ami                         = "ami-0e472ba40eb589f49"
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.master.id]
  key_name                    = "aws_adhoc"
  count                       = 1
  associate_public_ip_address = true
  
  tags = { 
    Name = "Master Server"
    ansibleFilter = "K8S01"
  }

}

resource "aws_instance" "worker" {
  ami                         = "ami-0e472ba40eb589f49"
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.worker.id]
  key_name                    = "aws_adhoc"
  count                       = 1
  associate_public_ip_address = true

  tags = {
    Name = "Worker Server"
    ansibleFilter = "K8S01"
 }
}

# --------------- write inventory file ---------------------
resource "local_file" "inventory" {
  depends_on         = [
    aws_instance.master,
    aws_instance.worker
  ]

  filename           = "inventory"
  file_permission    = "0644"
  content            = <<-EOF
[masters]
master ansible_host=${aws_eip.master_static_ip.public_ip} 

[workers]
worker ansible_host=${aws_eip.worker_static_ip.public_ip}

EOF
}

# -------------- launch Ansible to deploy k8s on these resources -----------------

resource "null_resource" "null1" {
  depends_on = [
     local_file.inventory
  ]

  provisioner "local-exec" {
    command = "sleep 60"
  }

  provisioner "local-exec" {
     command = "ansible-playbook -i ./inventory --private-key ${var.private_key} -e 'pub_key=${var.public_key}' playbook.yaml"
  }

}

# --------------- get static IP addresses ------------------

resource "aws_eip" "master_static_ip" {
  instance = aws_instance.master[0].id
  tags = { Name = "master Server IP" }
}

resource "aws_eip" "worker_static_ip" {
  instance = aws_instance.worker[0].id
  tags = { Name = "worker Server IP" }
}