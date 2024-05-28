data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical account ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
resource "tls_private_key" "key_for_webapp_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "sonar_keypair" {
  key_name   = "sonar_keypair"
  public_key = tls_private_key.key_for_webapp_keypair.public_key_openssh
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.subnet-public-1.id
  user_data              = filebase64("user-data.sh")
  vpc_security_group_ids = [aws_security_group.sonarQube-SG.id]

  tags = {
    Name = "SonarQube_VM"
  }
}