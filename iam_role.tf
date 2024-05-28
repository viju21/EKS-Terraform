data "aws_iam_policy" "AmazonEKSServiceRolePolicy" {
  name = "AmazonEKSServiceRolePolicy"
}
data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  name = "AmazonEKSClusterPolicy"
}
data "aws_iam_policy" "AmazonEKSVPCResourceController" {
  name = "AmazonEKSVPCResourceController"
}
resource "aws_iam_role" "EKS_Cluster_Role" {
  name = "EKS_Cluster_Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "AmazonEKSServiceRolePolicy_attachment" {
  name = "AmazonEKSServiceRolePolicy_attachment"
  role = aws_iam_role.EKS_Cluster_Role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy.AmazonEKSServiceRolePolicy.policy
}

resource "aws_iam_policy_attachment" "AmazonEKSClusterPolicy_attachment" {
  name       = "AmazonEKSClusterPolicy_attachment"
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
  roles      = [aws_iam_role.EKS_Cluster_Role.name]
}

resource "aws_iam_policy_attachment" "AmazonEKSVPCResourceController_attachment" {
  name       = "AmazonEKSVPCResourceController_attachment"
  policy_arn = data.aws_iam_policy.AmazonEKSVPCResourceController.arn
  roles      = [aws_iam_role.EKS_Cluster_Role.name]
}

# Node group IAM Role

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  name = "AmazonEKSWorkerNodePolicy"
}
data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}
data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  name = "AmazonEKS_CNI_Policy"
}

resource "aws_iam_policy" "create_delete_ebs_policy" {
  name        = "create_delete_ebs_policy"
  description = "Allows EKS nodes to create and delete EBS volumes"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeVolumes", // To list volumes before deleting
          "ec2:AttachVolume",
          "ec2:CreateTags",  // Optionally, for attaching
          "ec2:DetachVolume" // Optionally, for detaching
        ]
        Resource = "*" // Or restrict to specific volume types/tags
      },
    ]
  })
}

resource "aws_iam_role" "AmazonEKSNodeRole" {
  name = "AmazonEKSNodeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "AmazonEKSWorkerNodePolicy_attachment" {
  name       = "AmazonEKSWorkerNodePolicy_attachment"
  policy_arn = data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn
  roles      = [aws_iam_role.AmazonEKSNodeRole.name]
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_attachment" {
  name       = "AmazonEC2ContainerRegistryReadOnly_attachment"
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
  roles      = [aws_iam_role.AmazonEKSNodeRole.name]
}
resource "aws_iam_policy_attachment" "AmazonEKS_CNI_Policy_attachment" {
  name       = "AmazonEKS_CNI_Policy_attachment"
  policy_arn = data.aws_iam_policy.AmazonEKS_CNI_Policy.arn
  roles      = [aws_iam_role.AmazonEKSNodeRole.name]
}
resource "aws_iam_policy_attachment" "eks_nodegroup_attachment" {
  name       = "eks_nodegroup_attachment"
  policy_arn = aws_iam_policy.create_delete_ebs_policy.arn
  roles      = [aws_iam_role.AmazonEKSNodeRole.name]
}
resource "aws_iam_policy_attachment" "eks_cluster_attachment" {
  name       = "eks_cluster_attachment"
  policy_arn = aws_iam_policy.create_delete_ebs_policy.arn
  roles      = [aws_iam_role.EKS_Cluster_Role.name]
}