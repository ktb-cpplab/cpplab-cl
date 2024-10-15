region = "ap-northeast-2"

vpc_cidr = "192.170.0.0/16"
public_subnet_cidr = "192.170.1.0/24"
private_subnet_cidr = "192.170.2.0/24"
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

key_name = "cpplab-keypair"

instance_type = "t2.micro"
nat_instance_type = "t2.micro"

nat_ami = "ami-0e0ce674db551c1a5"
instance_ami = "ami-062cf18d655c0b1e8"

security_group_id = "sg-0123456789abcdef0"

tags = {
  Name        = "MyInstance"
  Environment = "dev"
  ManagedBy   = "terraform"
}