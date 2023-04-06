#!/bin/bash

# Interactive script to deploy 2 load balanced (public) virtuals machines (Azure IAAS) linked to Azure Mariadb service (SAAS), the user will access them through the load balancer.
# Successfuly tested with azure-cli : 2.46.0 
echo "*****Deployment starting*****"
echo "Name of the resource group you wish to create ? (westeurope) : "
read RSG
az group create \
    --name $RSG \
    --location westeurope 

# Virtual network for your Vms, used as a backend-pool for your load balancer, Azure Bastion will also use one of his subnets
echo "Virtual network name ? :"
read vnet
echo "Subnet name : "
read mysubnet
az network vnet create \
    --resource-group $RSG \
    --location westeurope \
    --name $vnet \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name $mysubnet \
    --subnet-prefixes 10.1.0.0/24 \

# Public IP to access the content of your web servers (Load balancer Frontend IP)
echo "Name of the Public Frontend IP for the load balancer ? :"
read myPublicIP
az network public-ip create \
    --resource-group $RSG \
    --name $myPublicIP \
    --sku Standard \
    --zone 1 

# Standard load balancer creation
echo "Name of your new Load balancer ? :"
read MYLB
echo "Name of your new FrontendIP configuration ? :"
read frontendPUBIP
echo "Name of your new Backendpool ? :"
read BACKpool
az network lb create \
    --resource-group $RSG \
    --name $MYLB \
    --sku Standard \
    --public-ip-address $myPublicIP \
    --frontend-ip-name $frontendPUBIP \
    --backend-pool-name $BACKpool \
    --no-wait 
    

# Probe that will monitor your http traffic 
echo "Name your new probe? :"
read MYPROBE
az network lb probe create \
    --resource-group $RSG \
    --lb-name $MYLB \
    --name $MYPROBE \
    --protocol tcp \
    --port 80 \
    --no-wait true

# Network traffic you wish to balance (HTTP:80 in this example)
echo "Name of your new Load balancing rule ? : "
read LBrule
az network lb rule create \
    --resource-group $RSG \
    --lb-name $MYLB \
    --name $LBrule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name $frontendPUBIP \
    --backend-pool-name $BACKpool \
    --probe-name $MYPROBE \
    --disable-outbound-snat true \
    --idle-timeout 15 \
    --enable-tcp-reset true \
    --no-wait true

# Standard firewall to deploy for your ressources
echo "Name of the new security group ? :" 
read MYNSG
az network nsg create \
    --resource-group $RSG \
    --name $MYNSG \
    --no-wait true

# Allowing inbound traffic to your virtual network through the port 80 :
echo "Name of the new security group rule for port 80 ? :"
read MYnsgload
az network nsg rule create \
    --resource-group $RSG \
    --nsg-name $MYNSG \
    --name $MYnsgload \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 80 \
    --access allow \
    --priority 200 \
    --no-wait true

echo "Name of the new security group rule for port 22 ? :"
read MYnsgload
az network nsg rule create \
    --resource-group $RSG \
    --nsg-name $MYNSG \
    --name $MYnsgload \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 22 \
    --access allow \
    --priority 210 \
    --no-wait true


# Network interfaces creation for your Vms
echo "Creation of two Network interfaces..."
array=(myNicVM1 myNicVM2)
  for vmnic in "${array[@]}"
  do
    az network nic create \
        --resource-group $RSG \
        --name $vmnic \
        --vnet-name $vnet \
        --subnet $mysubnet \
        --network-security-group $MYNSG \
        --no-wait true 
  done
  
# Vm creation 
echo "Name of your first VM ? :"
read VM1
echo "Name of the admin username? : "
read adminu1
echo " Admin password ? will be used for your 2 vms : 
- The value must not be empty.
- Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character.
- The value must be between 12 and 72 characters long.) : "
read psswd
az vm create \
    --resource-group $RSG \
    --name $VM1\
    --nics myNicVM1 \
    --image UbuntuLTS \
    --admin-username $adminu1 \
    --admin-password $psswd \
    --zone 1 \
    --no-wait

echo "Name of your second VM ? :"
read VM2
echo "Name of the admin username? : "
read adminu2
az vm create \
    --resource-group $RSG \
    --name $VM2 \
    --nics myNicVM2 \
    --image UbuntuLTS \
    --admin-username $adminu2 \
    --admin-password $psswd \
    --zone 3 \
    --no-wait
 
# Add your VMS to the LB backendpool using their NICS
array=(myNicVM1 myNicVM2)
  for vmnic in "${array[@]}"
  do
    az network nic ip-config address-pool add \
     --address-pool $BACKpool \
     --ip-config-name ipconfig1 \
     --nic-name $vmnic \
     --resource-group $RSG \
     --lb-name $MYLB 
  done

az network lb inbound-nat-rule create \
    --backend-port 22 \
    --frontend-port 3100 \
    --lb-name $MYLB \
    --name inboundNATSSHVM1 \
    --protocol tcp \
    --resource-group $RSG \

az network nic ip-config inbound-nat-rule add \
    --resource-group $RSG \
    --nic-name myNicVM1  \
    --inbound-nat-rule inboundNATSSHVM1 \
    --lb-name $MYLB \
    --ip-config-name ipconfig1

az network lb inbound-nat-rule create \
    --backend-port 22 \
    --frontend-port 3101 \
    --lb-name $MYLB \
    --name inboundNATSSHVM2 \
    --protocol tcp \
    --resource-group $RSG \

az network nic ip-config inbound-nat-rule add \
    --resource-group $RSG \
    --nic-name myNicVM2 \
    --inbound-nat-rule inboundNATSSHVM2 \
    --lb-name $MYLB \
    --ip-config-name ipconfig1

# Nat Gateway creation
echo "NAT Gateway Public IP name ? : "
read NATgatewayIP
az network public-ip create \
    --resource-group $RSG \
    --name $NATgatewayIP \
    --sku Standard \
    --zone 1 

echo "NAT Gateway name ? : "
read NATgateway
az network nat gateway create \
    --resource-group $RSG \
    --name $NATgateway \
    --public-ip-addresses $NATgatewayIP \
    --idle-timeout 10 

# Configure the source subnet in virtual network to use a specific NAT gateway
echo "Configuring the source subnet in vnet to use specific NAT gateway..."
az network vnet subnet update \
    --resource-group $RSG \
    --vnet-name $vnet \
    --name $mysubnet \
    --nat-gateway $NATgateway \
    --no-wait true
  
echo "Enter your dbadmin name: "
read DBadmin
echo "Name your db :"
read DBname
echo "Admin DB Password: "
read Adminpsswd
az mariadb server create \
    --resource-group $RSG \
    --name $DBname \
    --location westeurope \
    --admin-user $DBadmin \
    --admin-password $Adminpsswd \
    --sku-name GP_Gen5_2 \
    --version 10.2 \
    --ssl-enforcement Disabled 

# To allow your vm to access the db through the NAT gateway, you'll need to add a Mariadb firewall rule with the NATgateway public IP
