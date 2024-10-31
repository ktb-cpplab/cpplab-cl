resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id

  # IAM 인스턴스 프로파일을 조건부로 연결
  iam_instance_profile = var.iam_instance_profile != null ? var.iam_instance_profile : null

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}

# EC2 인스턴스를 타겟 그룹에 등록하는 리소스 추가
resource "aws_lb_target_group_attachment" "this" {
  count            = var.target_group_arn != null ? 1 : 0   # target_group_arn이 null이 아닐 때만 리소스 생성
  target_group_arn = var.target_group_arn                   # 타겟 그룹 ARN을 변수로 지정
  target_id        = aws_instance.this.id                   # 생성된 EC2 인스턴스 ID
}