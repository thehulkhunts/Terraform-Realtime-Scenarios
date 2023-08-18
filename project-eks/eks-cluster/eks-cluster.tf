resource "aws_eks_cluster" "eks-cluster-01" {
  name = "eks-cluster-production"
  version = "1.26"
  role_arn = var.eks-iam-role

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true

    subnet_ids = [
        var.subnet-01,
        var.subnet-02
    ]
  }
  depends_on = [var.aws-iam-policy-attachment]
}

output "eks-cluster-name" {
  value = aws_eks_cluster.eks-cluster-01.name
}