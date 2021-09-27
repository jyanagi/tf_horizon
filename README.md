# tf_horizon

The following terraform plan was created to simplify Day 2 security operations of Horizon through NSX-T.

The only file that needs modification is the variables.tf to fit the IP addressing, naming standards or tag criteria for an organization.

Instructions:

1.  Install Terraform (https://learn.hashicorp.com/tutorials/terraform/install-cli) 

2.  Clone this GIT repository: git clone https://github.com/jyanagi/tf_horizon.git

3.  Run the following commands:
    terraform init
    - Initializes the Terraform provider
    
    terraform plan
    - Pre-Check before deployment of Terraform Plan
    
    terraform apply -auto-approve
    - Deploys objects as defined in Terraform Plan
    - -auto-approve removes confirmation prompt.

Once deployed, 10 security groups (HZN-GRP-###), 27 services (HZN-SVC-###), and 44 DFW rules (under Applications > Horizon Security Policies) are deployed
