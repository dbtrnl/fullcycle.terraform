resource "aws_security_group" "sg" {
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.prefix}-sg"
    }
    /*
     Tudo que está dentro do security group tem acesso a tudo que está fora
     Cluster tem acesso irrestrito à internet pública
     Todo o tráfego em todo protocolo em todas as portas, independentemente do destino
     podem ter acesso
    */
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
}

resource "aws_iam_role" "cluster" {
  name = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "Service": "eks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
  POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  role = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSCLusterPolicy" {
  role = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSCLusterPolicy"
}

resource "aws_cloudwatch_log_group" "log" {
    name = "/aws/eks/${var.prefix}-${var.cluster_name}/cluster"
    retention_in_days = var.retention_days
}

resource "aws_eks_cluster" "cluster" {
    name = "${var.prefix}-${var.cluster_name}"
    role_arn = aws_iam_role.cluster.arn // ARN da Role criada para esse cluster
    enabled_cluster_log_types = ["api","audit"]

    vpc_config {
      subnet_ids = var.subnet_ids // aws_subnet.subnets[*].id // Todas as subnets criada
      security_group_ids = [aws_security_group.sg.id]
    }
    depends_on = [
        aws_cloudwatch_log_group.log,
        aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
        aws_iam_role_policy_attachment.cluster-AmazonEKSCLusterPolicy,
    ]
}

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
    subnet_ids = var.subnet_ids
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
