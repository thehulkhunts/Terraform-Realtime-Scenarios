resource "aws_eks_node_group" "eks-ng-01" {
  cluster_name = var.cluster-name
  node_group_name = "eks-nodegroup-01"
  node_role_arn = var.node-role

  subnet_ids = [
    var.private-subnet-01,
    var.private-subnet-02
  ]
  scaling_config {
    desired_size = 2
    min_size = 2
    max_size = 5
  }
  ami_type             = "AL2_x86_64"
  capacity_type        = "ON_DEMAND"
  instance_types       = ["t2.medium"]
  disk_size            =  20
  force_update_version =  false
  version              =  "1.27"

  labels = {
     Name = "eks-nodegroups"
     role = "nodes-general"
  }
   depends_on = [ var.worker-node,
                  var.eks-cni,
                  var.ec2-readonly  ]
}
