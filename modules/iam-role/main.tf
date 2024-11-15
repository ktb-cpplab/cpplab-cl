# IAM Role 생성
resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
  tags               = var.tags
}

# 인라인 정책 생성 (선택적 적용)
resource "aws_iam_role_policy" "inline_policy" {
  count = length(var.inline_policies) > 0 ? 1 : 0
  name  = "${var.role_name}-inline-policy"
  role  = aws_iam_role.this.name

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = var.inline_policies
  })
}

# IAM Role에 관리형 정책 연결
resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline_policy_attachment" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.this.name
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = var.policy_statements
  })
} 


# 인스턴스 프로파일 생성 (필요시 적용)
resource "aws_iam_instance_profile" "this" {
  //count = var.create_instance_profile ? 1 : 0
  name  = "${var.role_name}-instance-profile"
  role  = aws_iam_role.this.name
}