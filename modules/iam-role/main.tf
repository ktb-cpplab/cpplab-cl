# IAM Role 생성
resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
  tags               = var.tags
}

# 인라인 정책 생성
resource "aws_iam_policy" "inline_policy" {
  count = length(var.policy_statements) > 0 ? 1 : 0
  name  = "${var.role_name}-inline-policy"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = var.policy_statements
  })
}

# IAM Role에 정책 연결
resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "this" {
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.this.name
}