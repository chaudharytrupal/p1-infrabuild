# Steps to Install the Infrastructure:

    1. First deploy the Prod/Network by doing terraform init validate plan and apply
    2. Secondly move to the Staging/Network folder and deploy it (Peering defined in staging so it needs prod network already deployed)
    3. Next deploy the webservers/VMs in both staging and prod environment in any order. For that to happen, ssh keys need to be created in both folders. For that, [ssh-keygen -t rsa -f prod] & [ssh-keygen -t rsa -f staging] needs to be executed in respective folders of webservers.
    4. Also, your public ip needs to be changed in variables.tf in staging/webservers -> line 23 and the bucket names need to be changed in almost every config.tf and data resources in respective main.tfs.

# Steps to Destroy/Clean up the Infrastructure:

    1. First, the Webservers in both prod and staging need to be destroyed [terraform destory -auto-approve]
    2. After that, the staging/network needs to be destroyed which will delete the NATGW and Peering connections
    3. Lastly, the prod/network can be deleted successfully from here on.

