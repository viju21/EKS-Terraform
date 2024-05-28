resource "aws_security_group" "sonarQube-SG" {
  name        = "sonarQube-SG"
  description = "Allow port 9000 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.webapp_VPC.id

  tags = {
    Name = "sonarQube-SG"
  }
}
resource "aws_security_group_rule" "allow_port_9000_to_sonar_VM" {
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sonarQube-SG.id
}
resource "aws_security_group_rule" "outbound_allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sonarQube-SG.id
  from_port         = 0
}