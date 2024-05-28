
resource "aws_eks_cluster" "webapp" {
  name     = "webapp"
  role_arn = aws_iam_role.EKS_Cluster_Role.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet-public-1.id, aws_subnet.subnet-public-2.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [aws_iam_role.EKS_Cluster_Role]
}

output "endpoint" {
  value = aws_eks_cluster.webapp.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.webapp.certificate_authority[0].data
}