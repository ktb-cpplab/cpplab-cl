# IAM 역할 생성
resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = var.assume_role_policy

  tags = merge(var.tags, {
    Name = var.role_name
  })
}

# IAM 역할에 정책을 연결
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# IAM 인스턴스 프로파일
resource "aws_iam_instance_profile" "this" {
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.this.name
}