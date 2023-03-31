#!/bin/bash 

#This is a script to create at least two VM with a load balancer paired with the Azure Mariadb database service

#Variable Pool :

RSG=Brief7Tom
myVNet=VnLoad
myBackEndSubnet=backload
myPublicIP=Publicipfrontload
myLB=Loadb7
myFrontEnd=Frontip
myBackEndPool=bpoolload
myHealthProbe=Httpprobe
myHTTPRule=Httpload
myNSG=NSGLOAD
myNSGRuleHTTP=HTTPin
psswd=@Azurev69007
myVM1=Vm1l
myVM2=Vml2
myNATgateway=NatIP
myNATgatewayIP=NATGWIP
DBname=mrdbtomb7
DBadmin=rooTom

# Main resource group creation :

az group create \
    --name $RSG \
    --location westeurope

# Virtual network creation :

az network vnet create \
    --resource-group $RSG \
    --location westeurope \
    --name $myVNet \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name $myBackEndSubnet \
    --subnet-prefixes 10.1.0.0/24

# Public Ip for the LB frontendIP
az network public-ip create \
    --resource-group $RSG \
    --name $myPublicIP \
    --sku Standard \
    --zone 1

# Load blaancer creation

az network lb create \
    --resource-group $RSG \
    --name $myLB \
    --sku Standard \
    --public-ip-address $myPublicIP \
    --frontend-ip-name $myFrontEnd \
    --backend-pool-name $myBackEndPool

#Probe for HTTP traffic 
az network lb probe create \
    --resource-group $RSG \
    --lb-name $myLB \
    --name $myHealthProbe \
    --protocol tcp \
    --port 80

#Rule for balancing of HTTP traffic

az network lb rule create \
    --resource-group $RSG\
    --lb-name $myLB \
    --name $myHTTPRule \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name $myFrontEnd \
    --backend-pool-name $myBackEndPool \
    --probe-name $myHealthProbe \
    --disable-outbound-snat true \
    --idle-timeout 15 \
    --enable-tcp-reset true

#Network security group creation

az network nsg create \
    --resource-group $RSG \
    --name $myNSG

#Opening of the port 80 for inbound HTTP traffic
az network nsg rule create \
    --resource-group $RSG \
    --nsg-name $myNSG \
    --name $myNSGRuleHTTP \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 80 \
    --access allow \
    --priority 200

#Creation of the BastionHost
az network vnet subnet create \
    --resource-group $RSG \
    --name AzureBastionSubnet \
    --vnet-name $myVNet \
    --address-prefixes 10.1.1.0/24

az network public-ip create --resource-group $RSG --name MyIp --sku Standard --location westeurope

az network bastion create --name MyBastion --public-ip-address MyIp --resource-group $RSG --vnet-name $myVNet --location westeurope

#Creation of 2 NICS to attach to VMS
array=(myNicVM1 myNicVM2)
  for vmnic in "${array[@]}"
  do
    az network nic create \
        --resource-group $RSG \
        --name $vmnic \
        --vnet-name $myVNet \
        --subnet $myBackEndSubnet \
        --network-security-group $myNSG
  done

#VM creation 
az vm create \
    --resource-group $RSG \
    --name $myVM1 \
    --nics myNicVM1 \
    --image UbuntuLTS \
    --admin-username azuretom \
    --admin-password $psswd \
    --zone 1 \
    --no-wait

az vm create \
    --resource-group $RSG \
    --name $myVM2 \
    --nics myNicVM2 \
    --image UbuntuLTS \
    --admin-username azuretom \
    --admin-password $psswd \
    --zone 3 \
    --no-wait

# Add your VMS to the LB backendpool using their NICS
array=(myNicVM1 myNicVM2)
  for vmnic in "${array[@]}"
  do
    az network nic ip-config address-pool add \
     --address-pool $myBackEndPool \
     --ip-config-name ipconfig1 \
     --nic-name $vmnic \
     --resource-group $RSG \
     --lb-name $myLB
  done

# Nat gateway creation 
az network public-ip create \
    --resource-group $RSG \
    --name $myNATgatewayIP \
    --sku Standard \
    --zone 1

az network nat gateway create \
    --resource-group $RSG \
    --name $myNATgateway \
    --public-ip-addresses $myNATgatewayIP \
    --idle-timeout 10

#Configure the source subnet in virtual network to use a specific NAT gateway resource
az network vnet subnet update \
    --resource-group $RSG \
    --vnet-name $myVNet \
    --name $myBackEndSubnet \
    --nat-gateway $myNATgateway

#Azure Mariadb service creation 
az mariadb server create \
    --resource-group $RSG \
    --name $DBname \
    --location westeurope \
    --admin-user $DBadmin \
    --admin-password @Azurev69007 \
    --sku-name GP_Gen5_2 \
    --version 10.2

#Azure Mariadb firewall rule creation 
az mariadb server firewall-rule create \
    --resource-group $RSG \
    --server $DBname \
    --name AllowMyIP \
    --start-ip-address 10.1.0.0 \
    --end-ip-address 10.1.0.0
