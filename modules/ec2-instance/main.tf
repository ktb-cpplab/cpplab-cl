resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id

  # IAM 인스턴스 프로파일을 조건부로 연결
  iam_instance_profile = var.iam_instance_profile != null ? var.iam_instance_profile : null

  # EBS 볼륨 설정 추가
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp2"  # 볼륨 유형을 설정 (예: gp2, gp3)
  }

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}