resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  key_name   = "terraform-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_sensitive_file" "key" {
  content  = tls_private_key.key.private_key_pem
  filename = var.key_filename
}

resource "aws_security_group" "default" {
  name        = "terraform-sg"
  description = "Allow SSH from anywhere and all outbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  description       = "SSH from the world"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "proxy_ingress" {
  type              = "ingress"
  description       = "Allow world access to proxy"
  from_port         = 3128
  to_port           = 3128
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-*-server-*"]
  }
}

resource "aws_instance" "default" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.default.id
  ]
  subnet_id = var.subnet_id
  root_block_device {
    volume_size = var.disk_size
  }
  tags = {
    Name = "terraform-instance"
  }
}

# associate elastic ip
resource "aws_eip" "ip" {
  instance = aws_instance.default.id
  domain   = "vpc"
}

resource "null_resource" "commands" {
  depends_on = [aws_instance.default]
  connection {
    type        = "ssh"
    host        = aws_eip.ip.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.key.private_key_pem
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo NEEDRESTART_MODE=a apt upgrade -y",
      "sudo NEEDRESTART_MODE=a apt install squid -y",
      "sudo NEEDRESTART_MODE=a apt install apache2-utils -y",
      "sudo htpasswd -b -c /etc/squid/passwd ${var.proxy_username} ${var.proxy_password}",
      "sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak",
    ]
  }
}

# send file to instance
resource "null_resource" "send_file" {
  depends_on = [null_resource.commands]
  connection {
    type        = "ssh"
    host        = aws_eip.ip.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.key.private_key_pem
  }
  provisioner "file" {
    source      = "modules/vm/squid.conf"
    destination = "/home/ubuntu/squid.conf"
  }
}

resource "null_resource" "restart_squid" {
  depends_on = [
    null_resource.send_file
  ]
  connection {
    type        = "ssh"
    host        = aws_eip.ip.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.key.private_key_pem
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/squid.conf /etc/squid/squid.conf",
      "sudo systemctl enable squid",
      "sudo systemctl restart squid",
    ]
  }
}
