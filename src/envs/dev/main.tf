terraform { 
  cloud { 
    
    organization = "poridh_iac" 

    workspaces { 
      name = "poridhi-k3s" 
    } 
  } 
}

module "poiridhi_dev" {
  source = "/Users/nafiz/Code/VS_Code/k3s_terraform_github/src/blueprint"

  vpc_name = "poridhi-vpc"
}
