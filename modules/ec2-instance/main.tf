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