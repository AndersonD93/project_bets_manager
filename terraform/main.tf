# Run init/plan/apply with "backend" commented-out (ueses local backend) to provision Resources (Bucket, Table)
# Then uncomment "backend" and run init, apply after Resources have been created (uses AWS)


terraform {
  backend "s3" {
    bucket         = "cc-tf-state-backend-ci-cd-ajduran"
    key            = "tf-infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true  
    dynamodb_table = "terraform-state-locking-ajduran2"
  }
}

provider "aws" {
  region = "us-east-1"
}


module "resources" {
  source = "./modules/resources"

  # Resoruces Input Vars
  s3_list_name = local.s3_list_name
  dynamo_tables_list_name = local.dynamo_tables_list_name
}


module "tf-state" {
  source      = "./modules/tf-state"
  bucket_name = "cc-tf-state-backend-ci-cd-ajduran"
}

