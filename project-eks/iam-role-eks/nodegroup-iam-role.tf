resource "aws_iam_role" "eks-node-group-iam-role" {
  name = "eks-node-group-iam-role"

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

resource "aws_iam_role_policy_attachment" "nodegroup-policy-attachment" {
  role = aws_iam_role.eks-node-group-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks-node-group-iam-role.name

}

resource "aws_iam_role_policy_attachment" "ec2-container-registry" {
     policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
     role = aws_iam_role.eks-node-group-iam-role.name
}

output "node-role" {
    value = aws_iam_role.eks-node-group-iam-role.arn
}

output "workder-node" {
  value = aws_iam_role_policy_attachment.nodegroup-policy-attachment.id
}
output "eks-cni" {
  value = aws_iam_role_policy_attachment.eks-cni-policy.id
}

output "ec2-readonly" {
  value = aws_iam_role_policy_attachment.ec2-container-registry.id
}