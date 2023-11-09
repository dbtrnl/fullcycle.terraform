resource "aws_iam_role" "node" {
  name = "${var.prefix}-${var.cluster_name}-role-node"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
  POLICY
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "node-1" {
    cluster_name = aws_eks_cluster.cluster.name
    node_group_name = "node-1"
    node_role_arn = aws_iam_role.node.arn // Na aula foi usado "role_arn"
    subnet_ids = aws_subnet.subnets[*].id // Na aula foi usado "subnet"
    instance_types = ["t3.medium"] // É o default (ver docs)

    scaling_config {
      desired_size = var.desired_size
      min_size = var.min_size
      max_size = var.max_size
    }

    depends_on = [ 
        aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
     ]
}

resource "aws_eks_node_group" "node-2" {
    cluster_name = aws_eks_cluster.cluster.name
    node_group_name = "node-2"
    node_role_arn = aws_iam_role.node.arn // Na aula foi usado "role_arn"
    subnet_ids = aws_subnet.subnets[*].id // Na aula foi usado "subnet"
    instance_types = ["t3.micro"] // Faz parte do free tier, ver https://aws.amazon.com/ec2/pricing/

    scaling_config {
      desired_size = var.desired_size
      min_size = var.min_size
      max_size = var.max_size
    }

    depends_on = [ 
        aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
     ]
}
