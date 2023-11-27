import pulumi
from pulumi_aws import ec2, rds, iam

#Create a VPC for our infrastructure
vpc = ec2.Vpc("main", cidr_block="10.0.0.0/16")

#Create a subnet within the VPC
subnet = ec2.Subnet("main", cidr_block="10.0.1.0/24", vpc_id=vpc.id)

# Presentation Layer - EC2 instance for the webserver
web_instance = ec2.Instance('web-server-instance',
                            instance_type='t2.micro', # free tier instance
                            ami='ami-0cfd0973db26b893b', # latest Amazon Linux AMI 
                            vpc_security_group_ids=[],
                            subnet_id=subnet.id,
                            tags={'Name': 'web-server-instance'})

# Database Layer - RDS instance for the database server
db_instance = rds.Instance("db-instance",
                           engine="mysql",
                           engine_version="5.7",
                           instance_class="db.t2.micro", # free tier instance
                           username="admin_user",
                           password="admin_password",
                           allocated_storage=10, # GB
                           skip_final_snapshot=True,
                           publicly_accessible=True,
                           vpc_security_group_ids=[],
#                           db_subnet_group_name=subnet.id,
                           tags={'Name': 'db-instance'})

# IAM role for the app layer
role = iam.Role('app-layer-role',
                assume_role_policy={ "Version": "2012-10-17",
                                     "Statement": [ { "Effect": "Allow",
                                                      "Principal": {"Service": "ec2.amazonaws.com"},
                                                      "Action": "sts:AssumeRole"} ] })

pulumi.export('webserver_id', web_instance.id)
pulumi.export('db_id', db_instance.id)
pulumi.export('role_id', role.id)

