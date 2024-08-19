data "aws_iam_policy_document" "rds_proxy_assume_role_policy_document" {
  statement {
    principals {  # 誰が (RDSが)
      type        = "AWS"
      identifiers = ["arn:aws:iam::197086462522:role/rds-proxy-role"]
    }
    actions = ["sts:AssumeRole"]  # 何をして　(STSからIAM roleをassumeして)
    effect  = "Allow"  # 良い
  }
}

data "aws_iam_policy_document" "rds_proxy_policy_document" {
  version = "2012-10-17"
  statement {
    resources = ["arn:aws:secretsmanager:*:*:*"]  # 誰に (AWS Secrets Managerに対して)
    actions = [  # 何をして (以下4つの操作をして)
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    effect    = "Allow"  # 良い
  }
}

resource "aws_iam_policy" "rds_proxy_policy" {
  name        = "rds-proxy-policy"
  description = "Policy for RDS Proxy"
  policy      = data.aws_iam_policy_document.rds_proxy_policy_document.json
}

resource "aws_iam_role" "rds_proxy_role" {
  name               = "rds-proxy-role"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_assume_role_policy_document.json
  managed_policy_arns = [
    aws_iam_policy.rds_proxy_policy.arn,  # 作成したポリシーをアタッチ
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",  # AWS managedなポリシーをアタッチ
  ]
}