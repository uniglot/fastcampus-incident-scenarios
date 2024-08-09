module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.common_prefix}-cluster"
  cluster_version = local.eks_cluster_version

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  cluster_security_group_additional_rules = {
    postgres = {
      description                = "MySQL"
      protocol                   = "tcp"
      from_port                  = 3306
      to_port                    = 3306
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  eks_managed_node_groups = {
    primary = {
      min_size       = local.eks_ng_min_size
      max_size       = local.eks_ng_max_size
      desired_size   = local.eks_ng_desired_size
      instance_types = [local.eks_instance_type]
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Fastcampus = "true"
  }
}

data "http" "lb_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json"
}

resource "aws_iam_role" "lb_controller" {
  name = "${local.common_prefix}-lb-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com"
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Fastcampus = "true"
  }
}

resource "aws_iam_policy" "lb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.lb_iam_policy.response_body
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}

resource "aws_iam_role" "ebs_csi_driver" {
  name               = "${local.common_prefix}-ebs-csi-driver"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com"
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = {
    Fastcampus = "true"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = module.eks.cluster_name
  addon_name = "aws-ebs-csi-driver"
  addon_version = "v1.32.0-eksbuild.1"

  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
}

resource "kubernetes_service_account" "lb_controller_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller.arn
    }
  }

  depends_on = [aws_iam_role.lb_controller, module.eks]
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"

  dynamic "set" {
    for_each = [
      { name = "clusterName", value = module.eks.cluster_name },
      { name = "serviceAccount.create", value = "false" },
      { name = "serviceAccount.name", value = "aws-load-balancer-controller" },
      { name = "region", value = local.region },
      { name = "vpcId", value = module.vpc.vpc_id }
    ]

    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  depends_on = [kubernetes_service_account.lb_controller_sa]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server"

  depends_on = [ module.eks ]
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  create_namespace = true

  set {
    name  = "grafana.adminPassword"
    value = "adminadmin"
  }

  set {
    name  = "grafana.sidecar.datasources.defaultDatasourceScrapeInterval"
    value = "10s"
  }

  depends_on = [module.eks, helm_release.aws_load_balancer_controller]
}