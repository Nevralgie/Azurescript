# Azure scripts for Load balanced Azure VMS

Automated azure infrastructure deployment scripts.

The rsg_vmcreate.bash script lets you edit it with your own variables, or use it with defaults values before executing it.

VMandLBinfra.bash is an interactive version, enter your variables when invited to. 

Both deploy this infrastructure configuration :

![Brieftest7](https://user-images.githubusercontent.com/93102912/229312285-b1c495e7-d794-4cd7-a232-776637e32321.png)

The VmLBNATrules.bash the same kind of infrastructure than the above, but uses inbound traffic nat rules to connect to the VMS. 

Here is the result : 

![infranatinbound](https://user-images.githubusercontent.com/93102912/230084068-4eb36064-70aa-4c12-a53d-762763c4563e.png)
