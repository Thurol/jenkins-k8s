resource "null_resource" "generate_ssh_key" {
  provisioner "local-exec" {
    command     = <<EOT
      if [ ! -f $HOME/.ssh/id_rsa_k8s ]; then
        ssh-keygen -t rsa -b 2048 -f $HOME/.ssh/id_rsa_k8s -N '' -C "k8s-cluster-key"
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

}

data "local_file" "k8s_private_key" {
  filename   = pathexpand("~/.ssh/id_rsa_k8s")
  depends_on = [null_resource.generate_ssh_key]
}

data "local_file" "k8s_public_key" {
  filename   = pathexpand("~/.ssh/id_rsa_k8s.pub")
  depends_on = [null_resource.generate_ssh_key]
}

resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-cluster-key"
  public_key = data.local_file.k8s_public_key.content

  depends_on = [null_resource.generate_ssh_key]
}

resource "aws_ssm_parameter" "k8s_private_key" {
  name        = "/k8s/id_rsa_k8s"
  type        = "SecureString"
  value       = data.local_file.k8s_private_key.content
  description = "Clé privée pour les nœuds Kubernetes"

  depends_on = [null_resource.generate_ssh_key]
}

# Master Node
resource "aws_instance" "k8s_master" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.public.ids[0]
  key_name                    = aws_key_pair.k8s_key.key_name
  iam_instance_profile        = "LabInstanceProfile"
  associate_public_ip_address = true

  user_data = data.template_file.k8s_master.rendered

  vpc_security_group_ids = [aws_security_group.master_sg.id]

  tags = {
    Name = "k8s-master"
    Role = "K8sMaster"
  }
}

data "template_file" "k8s_master" {
  template = file("${path.module}/scripts/master_userdata.sh.tpl")

  vars = {
    AWS_REGION      = var.region
  }
}

# Worker Nodes
resource "aws_instance" "k8s_worker" {
  count                       = 2
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.public.ids[count.index % length(data.aws_subnets.public.ids)]
  key_name                    = aws_key_pair.k8s_key.key_name
  iam_instance_profile        = "LabInstanceProfile"
  associate_public_ip_address = true

  user_data = data.template_file.k8s_worker.rendered

  vpc_security_group_ids = [aws_security_group.worker_sg.id]

  tags = {
    Name = "k8s-worker-${count.index + 1}"
    Role = "K8sWorker"
  }
  depends_on = [aws_instance.k8s_master]
}

data "template_file" "k8s_worker" {
  template = file("${path.module}/scripts/worker_userdata.sh.tpl")

  vars = {
    AWS_REGION      = var.region
  }
}