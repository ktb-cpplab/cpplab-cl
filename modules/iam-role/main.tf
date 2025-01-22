# Local variables for clarity
locals {
  has_inline_policies = length(var.inline_policies) > 0
  has_policy_arns     = length(var.policy_arns) > 0
}

# IAM Role 생성
resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
  tags               = merge(var.tags, { ManagedBy = "Terraform" })
}

# 인라인 정책 (선택적 적용)
resource "aws_iam_role_policy" "inline_policies" {
  for_each = { for idx, policy in var.inline_policies : idx => policy }

  name   = "${var.role_name}-inline-policy-${each.key}"
  role   = aws_iam_role.this.name
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = each.value
  })
}

# IAM Role에 관리형 정책 연결
resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# IAM Instance Profile 생성
resource "aws_iam_instance_profile" "this" {
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.this.name

  lifecycle {
    prevent_destroy = false
  }
}
