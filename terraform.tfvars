region = "ap-northeast-2"

vpc_cidr = "192.170.0.0/16"
public_subnet_cidr = "192.170.1.0/24"
private_subnet_cidr = "192.170.2.0/24"
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

key_name = "cpplab-keypair"

instance_type = "t2.micro"
be_instance_type = "t3a.medium"
nat_instance_type = "t2.micro"

nat_ami = "ami-0e0ce674db551c1a5"
instance_ami = "ami-0e0a3f6889d16c659"  # docker 설치된 ami
jenkins_ami = "ami-0185cfa58cccb3358"   # jenkins ami (수정완료)
be_ami = "ami-008826d9fbd497026"
redis_ami = "ami-01ce306e867ff466f"
mt_ami = "ami-040c33c6a51fd5d96"


security_group_id = "sg-0123456789abcdef0"

tags = {
  Name        = "MyInstance"
  Environment = "dev"
  ManagedBy   = "terraform"
}