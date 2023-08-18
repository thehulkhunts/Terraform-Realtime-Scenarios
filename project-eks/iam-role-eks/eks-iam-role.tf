resource "aws_iam_role" "eks-iam-role" {
   name = "eks-iam-role"
   assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
   })
}

# create the role policy-attachment to the eks-cluster
# this policy will attach to above role, this
# role will be attached to eks-cluster

resource  "aws_iam_role_policy_attachment" "eks-cluster-policy-attachment" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role = aws_iam_role.eks-iam-role.name
}

output "eks-iam-role" {
  value = aws_iam_role.eks-iam-role.arn
}

output "aws-iam-policy-attachment" {
  value = aws_iam_role_policy_attachment.eks-cluster-policy-attachment.id
}