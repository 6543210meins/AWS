# Dokumentation für AWS, MAi 2023

## SSH - SSH over PowerShell

So erstellen Sie Private und Public Key

    ssh-keygen

Überprüfen ob id_rsa und id_rsa.pub existiert.

    cd
    ls -lah .ssh

## Git und CodeCommit

### 1. Ordner für die Reposetory erstellen

#### create a folder for the Reposetory

    mkdir "Foldername"
    
### 2. Name und Email konfigurieren 

in das verzeichnes des Reposetory wechseln

    cd path/"Foldername"

#### configuration name and email 

Befehl für die Konfiguration

    git config --global user.name "Mike Berndt" && git config --global user.email "Mike-Berndt@xxx.de"
    
das sind 2 befehle in einen Kommando, die mit && getrennt werden.


[Referenz-1 - Cloud9 in CodeCommit übertragen](https://docs.aws.amazon.com/de_de/codecommit/latest/userguide/setting-up-ide-c9.html)


[Referenz - 2 - Erste mit Git und und AWS CodeCommit ](https://docs.aws.amazon.com/codecommit/latest/userguide/getting-started.html)

### 3.  Mit CodeCommit verbinden

erstellen eines CodeCommit Reposetory Praktikum

#### conection with CodeCommit

     [aws-CodeCommit](https://console.aws.amazon.com/codesuite/codecommit/home)

#### Clonen des Reposetory

    git clone https://git-codecommit.eu-central-1.amazonaws.com/v1/repos/Praktikum-Berndt-Mike

### 4. Führen Sie am Terminal die folgenden Befehle zum Konfigurieren des Hilfsprogramms für AWS CLI-Anmeldeinformationen für HTTPS-Verbindungen aus:

##### configuration the helpprogramm for AWS CLI-loginiformation for https-connection

    git config --global credential.helper '!aws codecommit credential-helper $@'
    git config --global credential.UseHttpPath true
    
### 5. Datein in Reposetory hinzufügen 

#### add files for the Reposetory

    git add Dateiname -A or git add "Dateiname "(README.md)
    
#### add or Create File 

    git add -a or git add "Filename"gen

#### create or add a commit 

    git commit -m "commmit"
    
#### Upload Files

    git push

Log datei für die Commits anzeigen lassen

    git log
    
##Github Verbindungen
[Referenz - 2 - Erste mit Git und und AWS CodeCommit ](https://docs.aws.amazon.com/codecommit/latest/userguide/getting-started.html)

### 1. Reposetory Order erstellen

#### create a reposetory folder

    mkdir "Foldername"

### 2. Name und Email Konfiguration 

#### config a folder for reposetory

    git config --global user.name "name" && git config --global user.email "email"
    git init

### 3. Reposetory auf git hub erstellen

    Github.com ==> Reposetory ==> New

### 4. SSH Key erstellen und hinzufügen

#### create a SSH key

    ins root verzeichnis wechselen
    ssh-keygen
    3x Enter drüclen

### 5. Inhalt von der zuvor erstellten ~/.ssh/id_rsa.pub datei in die datei ~/.ssh/authorized_keys kopieren

    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys


    

### 6. Mit Git hub verbinden

#### conection with github

    ssh -T git@github.com
    git remote add origin "SSH-URL"     <== Reposetory auswählen => code => ssh
    git push -u origin master

### 7. Datein auf GitHub hochladen 

#### add or Create File 

    git add -a or git add "Filename"gen

#### create or add a commit 

    git commit -m "commmit"
    
#### Upload Files

    git push



 ## Sich per ssh over Powershell einloggen

[ssh-powershell](https://4sysops.com/archives/powershell-remoting-with-ssh-public-key-authentication/)

in EC2-Instanze (Cloud9) >> Sicherheitsgruppen >> neue Regel für eingehende Regeln hinzugefügt >> SSH from Anywhere


# NGINX

[NginX Installieren und Konfigurieren](https://towardsaws.com/creating-an-ec2-instance-through-aws-cli-b07c5870a904)

## Ec2 Instanz mit NGINX erstellen und AWS-CLI

1. Erstellen einer EC2 instanz mit Ubuntu 22.04
2. Erstellen eines Script, dass alle Pakete Updatet, NGinX und starten des Dienstes
3. Überprüfen ob NginX Dienste Gestartet sind 
4. Beenden der EC2 Instanze

## Keypar erstellen

PowerShell befehle

    aws ec2 create-key-pair --key-name MyTestKey --query 'KeyMaterial' --output text | out-file -encoding ascii -filepath MyTestKey.pem
    
Linux befehle

    aws ec2 create-key-pair --key-name NGINX-Berndt --query 'KeyMaterial' --output text > NGINX-Berndt.pem 

Testen ob Key erstellt wurde

    aws ec2 describe-key-pairs --key-name NGINX-Berndt
    

## Sicherheitsgruppen erstellen

fungiert als Firewall und steuert welcher Datenverkehr ein- oder ausgehend zugelassen wird

1. Sicherheitsgruppe erstellen
    [verschiedenen Sicherheitsgruppen Einstellungen](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-security-group.html)

    ec2 create-security-group --group-name berX-sg --description "sg für ec2-NginX"
    
2. eingehende Regeln für Sicherheitsgruppe erstellen

http (Wichtig GruppenID der zuvor angelegten Sicherheitsgruppe angeben)

    aws ec2 authorize-security-group-ingress --group-id <SecurityGroupId> --protocol tcp --port 80 --cidr 0.0.0.0/0
    
ssh  (Wichtig GruppenID der zuvor angelegten Sicherheitsgruppe angeben)

    aws ec2 authorize-security-group-ingress --group-id <SecurityGroupId> --protocol tcp --port 22 --cidr 0.0.0.0/0
    
3. Details anzeigen lassen


    aws ec2 describe-security-groups --group-ids <SecurityGroupId>

## EC2-Instanze erstellen und NginX installieren

1. Über AWS-Konsolenseite => EC2 => AMI_Kataloge eine Ubuntu 22.04 Server Image ID Kopieren (ami-04e601abe3e1a910f)
2. Script erstellen um den NGINX-Webservice zu Installieren und zu starten


    vim nginxscript.sh

bash_Code

    #!/bin/bash
    apt update -y
    apt upgrade -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx

3. Instanz mit folgenden Befehl erstellen


     aws ec2 run-instances --image-id ami-04e601abe3e1a910f --count 1 --instance-type t2.micro --key-name NGINX-Berndt --security-groups berndtX-sg  --user-data file://nginxscriptBerndt.sh
    
#### Überprüfen und Beenden der EC2 Instanz

EC2 => Instanzen => wenn Instanz betriebsbereit ist, dann öffentliche IPv4 kopieren

#### Überprüfen ob NGINX auf unserer Instanz installiert ist

IPv4 adresse in Browser einfügen und Eingabe taste drücken

## Verbindung mit SSH aufbauen

#### Dateirechte ändern 

    chmod 400 NGINX-Berndt.pem
    
#### SSH Verbindung mit neue ec2NginX

    ssh -i NGINX-Berndt.pem Ubuntu@52.59.249.130

#### Beenden der Instanz (wichtig InstanzID eingeben)

    aws ec2 terminate-instances --instance-ids i-0fff0b8e800c51908

####Verschieden Packet Manager unter Linux Distibutionen

Debian basierte >> apt-get, apt, Ubuntu, Linuxmint, kali linux
Archlinux Basierte >> pacman, yay>> Archlinux, Manjaro, Garuda Linux...
Fedora >> dnf
CentOS = Amazon Linux >> yum
OpenSuse > zypper
Gentoo >
BSD >
Alpine Linux > apk
pip (Python)
npm (NodeJS)
brew (MacOS)
cargo (Rust)
Verschiedene Shells
sh (shell)
bash (Bourn again Shell)
ksh (Korn Shell)
csh (C-Shell)
zsh
fish-shell
PowerShell (Core)

#### Partitionierung
/EFI = 300 Mb => Format: FAT32/vFAT /boot = bis 512 Mb => Format: ext2/3/4 /swap = 1Gb RAM => 2Gb 2Gb RAM => 4Gb 4Gb RAM => 2Gb 12Gb RAM => Kein swap /root = ab 50 Gb /home = gemäß Anwender

## Tmux Multiplexor

    Ctrl + b --> Tastaturkürzel (Prefix)
    New Window --> Prefix + c
    Fenster Horizontaler Teilen --> Prefix + "
    Fenster Vertical Teilen --> Prefix + %  
    Session Liste --> Prefix + s    

## Enrichten einer Webseite auf NginX und Linux

[So richten Sie eine Website auf Nginx und Linux (Ubuntu & Debian) ein - Referenz 3](http://flsilva.com/blog/how-to-configure-a-website-on-nginx-and-linux-tutorial/)



## SSH Server

[Referenz 4 - Wie sichere ich mein open SSH Server ab ](https://www.tecmint.com/secure-openssh-server)

[Referenz 5 - Sicherheitspraktiken für OpenSSH-Server](https://www.cyberciti.biz/tips/linux-unix-bsd-openssh-server-best-practices.html)

## Zweite Instanz aufgesetzt

1. Keypaar erstellt
2. Sicherheitsgruppe erstellt
3. Portfreigabe von 80 und 22
4. nginx script geschrieben
5. EC2 Instanz mit dem neuen Keypaar erstellen une einbindung des nginx script
6. Starten und Testen



## Tmux Multiplexor
### Installation:

    sudo apt install tmux
    
### Tastenkombis (funktionieren von Haus aus in Cloud9):

    Ctrl + B ==> Haupttastaturkürzel (Prefix)
    Prefix + c ==> new window
    Prefix + " ==> Fenster horizontal teilen
    Prefix + % ==> Fenster vertikal teilen
    Prefix + s ==> Session Liste


## AWS EC2-Instanz mit AWS CLI erstellen
#### Wichtig!!! Alle DevOps <== Attribute müssen durch Namen ersetztwerden um doppelte Werte zu vermeiden
### 1. Erstellen einer VPC

#### Create a VPC

    AWS_VPC=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --query 'Vpc.{VpcId:VpcId}' \
    --output text)

#### Add a name tag to the VPC

    aws ec2 create-tags \
    --resources $AWS_VPC \
    --tags Key=Name,Value=DevOpsVPC         <==

### 2. Hostname und DNS-Unterstützung aktivieren 

#### Enable DNS hostnames

    aws ec2 modify-vpc-attribute \
    --vpc-id $AWS_VPC \
    --enable-dns-hostnames "{\"Value\":true}"

#### Enable DNS support

    aws ec2 modify-vpc-attribute \
    --vpc-id $AWS_VPC \
    --enable-dns-support "{\"Value\":true}"
    
### 3. öffentliches Subnetz erstellen

#### Create a public subnet

    AWS_PUBLIC_SUBNET=$(aws ec2 create-subnet \
    --vpc-id $AWS_VPC \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --query 'Subnet.{SubnetId:SubnetId}' \
    --output text)

#### Add a name tag to the public subnet

    aws ec2 create-tags \
    --resources $AWS_PUBLIC_SUBNET \
    --tags Key=Name,Value=DevOpsPublicSubnet    <==
    
### 4. privates Subnetz erstellen

#### create a private subnet

    AWS_PRIVATE_SUBNET=$(aws ec2 create-subnet \
    --vpc-id $AWS_VPC \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1a \
    --query 'Subnet.{SubnetId:SubnetId}' \
    --output text)

#### Add a name tag to the private subnet

    aws ec2 create-tags \
    --resources $AWS_PRIVATE_SUBNET \
    --tags Key=Name,Value=DevOpsPrivateSubnet   <==
    
### 4. automatischen Zuweisung öffentlicher IP-Adressen im Subnetz

#### Enable auto-assign public IP on the public subnet

    aws ec2 modify-subnet-attribute \
    --subnet-id $AWS_PUBLIC_SUBNET \
    --map-public-ip-on-launch

### 5. Erstellen eines Internet-Gateways

#### create a Internet Gateway

    AWS_INTERNET_GATEWAY=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
    --output text)

#### Add a name tag to the Internet Gateway

    aws ec2 create-tags \
    --resources $AWS_INTERNET_GATEWAY \
    --tags Key=Name,Value=DevOpsInternetGateway <==
    
### 6. Erstellen eines NAT-Gateways

##### Wichtig!!! 

$AWS_EIP_ALLOCATION <==== wird nicht deklariert, daher muss man sich die ElastikIpID aus der Managementconsole kopieren

EC2 => im Navigationsbereich nach Elastic IPs suchen  => Zuordungs-ID kopieren => für $AWS_EIP_ALLOCATION ersetzen 


#### Get Elastic IP

    AWS_ELASTIC_IP=$(aws ec2 allocate-address \
    --domain vpc \
    --query 'AllocationId' \                    <====
    --output text)

#### Create a NAT gateway

    AWS_NAT_GATEWAY=$(aws ec2 create-nat-gateway \
    --subnet-id $AWS_PUBLIC_SUBNET \
    --allocation-id $AWS_EIP_ALLOCATION \
    --query 'NatGateway.{NatGatewayId:NatGatewayId}' \
    --output text)

#### Add a name tag to the NAT gateway

    aws ec2 create-tags \
    --resources $AWS_NAT_GATEWAY \
    --tags Key=Name,Value=DevOpsNATGateway  <==



### 7. Verbinden des Internet Gateway mit der VPC

#### Attach the Internet gateway to your VPC

    aws ec2 attach-internet-gateway \
    --vpc-id $AWS_VPC \
    --internet-gateway-id $AWS_INTERNET_GATEWAY \
    --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
    --output text


### 8. benutzerdefinierte Routing-Tabelle erstellen

#### Create a custom route table

    AWS_ROUTE_TABLE=$(aws ec2 create-route-table \
    --vpc-id $AWS_VPC \
    --query 'RouteTable.{RouteTableId:RouteTableId}' \
    --output text)

#### Add a name tag to the route table

    aws ec2 create-tags \
    --resources $AWS_ROUTE_TABLE \
    --tags Key=Name,Value=DevOpsRouteTable  <==

### 9. benutzerdefinierten Routing-Tabellenzuordnung

#### Create a custom route table association

    aws ec2 associate-route-table \
    --route-table-id $AWS_ROUTE_TABLE \
    --subnet-id $AWS_PUBLIC_SUBNET \
    --output text


### 10. Subnetz der Routingtabelle zu, um es zu einem öffentlichen Subnetz zu machen

#### Associate the subnet with route table, making it a public subnet

    aws ec2 create-route \
    --route-table-id $AWS_ROUTE_TABLE \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $AWS_INTERNET_GATEWAY \
    --output text

### 11. NAT-Gateway der Routingtabelle zu, um es zu einem privaten Subnetz zu machen

#### Associate the NAT gateway with the route table, making it a private subnet

    aws ec2 create-route \
    --route-table-id $AWS_ROUTE_TABLE \
    --destination-cidr-block 10.2.0.0/24 \
    --nat-gateway-id $AWS_NAT_GATEWAY \
    --output text

### 12. Sicherheitsgruppe erstellen

#### Create a security group

    AWS_SECURITY_GROUP=$(aws ec2 create-security-group \
    --group-name DevOpsSG \
    --description "DevOps Security Group" \
    --vpc-id $AWS_VPC \
    --query 'GroupId' \
    --output text)

#### Add a name tag to the security group

    aws ec2 create-tags \
    --resources $AWS_SECURITY_GROUP \
    --tags Key=Name,Value=DevOpsSG  <==

### 13. Regel zur Sicherheitsgruppe hinzufügen

#### Add a rule to the security group

##### Add SSH rule

    aws ec2 authorize-security-group-ingress \
    --group-id $AWS_SECURITY_GROUP \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --output text

##### Add HTTP rule

    aws ec2 authorize-security-group-ingress \
    --group-id $AWS_SECURITY_GROUP \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --output text

### 14. AMI-ID in eine Variable schreiben

Info!! diese kann man sich auch über die Managementkonsole => EC2 => Im Navigationsbereich auf AMI-Katalog klicken => Betriebsystem aussuchen => sich die ersten buchstaben und Zahlen kopeiern (ami-xxxxxxxxxx) 

#### Get the latest AMI ID

    AWS_AMI=$(aws ec2 describe-images \
    --owners 'amazon' \
    --filters 'Name=name,Values=amzn2-ami-hvm-2.0.20221004.0-x86_64-gp2' \
    'Name=state,Values=available' \
    --query 'sort_by(Images, &CreationDate)[-1].[ImageId]' \
    --output 'text')


### 15. Schlüsselpaar erstellen

#### Create a key pair

    aws ec2 create-key-pair \
    --key-name DevOpsKeyPair \          <==
    --query 'KeyMaterial' \
    --output text > DevOpsKeyPair.pem   <==

#### Change the permission of the key pair (dieser Befehl ist wichtig, da sonst keine verbindung mittels SSH aufgebaut werden kann)

    chmod 400 DevOpsKeyPair.pem         <== Hier muss der oben erstellte Dateiname mit endung stehen


### 16. Schreiben eines scriptes, dass das Installieren des Webservers automatisiert

Wichtig!!! Beim einbinden des Scripts bitte beachten welche Linux Distribution man verwendet und gegebenfalls den Packetmanager aendern

#### Create a bash script to update packages, install git and clone the repo, and run the script

    cat <<EOF > install.sh
    #!/bin/bash

    # Update packages
    sudo yum update -y

    # Install git
    sudo yum install git -y

    # Clone the repo
    git clone https://github.com/MKAbuMattar/install-and-setup-wordpress-on-amazon-linux-2.git

    # Run the script
    bash install-and-setup-wordpress-on-amazon-linux-2/script.sh mkabumattar 121612 121612 wordpressdb wordpressuser password       <==== hier den namen mkabumattar gegen den eigenen ersetzen und auch ggf. in der scriptdatei den Packetmanager aendern
    EOF

[nähere Infos zu dem Script](https://github.com/MKAbuMattar/install-and-setup-wordpress-on-amazon-linux-2)


### 17. Erstellen einer EC2 Instanz mit der einbindung des Scripts zur automatisierung


### Create an EC2 instance with the script

    AWS_EC2_INSTANCE=$(aws ec2 run-instances \
    --image-id $AWS_AMI \
    --instance-type t2.micro \
    --key-name DevOpsKeyPair \              <== den zuvor angelegten namen des Sicherheitsschluessel, nicht die Datei
    --monitoring "Enabled=false" \
    --security-group-ids $AWS_SECURITY_GROUP \
    --subnet-id $AWS_PUBLIC_SUBNET \
    --user-data file://install.sh \
    --private-ip-address 10.0.1.10 \
    --query 'Instances[0].InstanceId' \
    --output text)

#### Add a name tag to the EC2 instance

    aws ec2 create-tags \
    --resources $AWS_EC2_INSTANCE \
    --tags "Key=Name,Value=DevOpsInstance"  <==


### 18. Staus der EC2-Instanz überprüfen 

#### Check the status of the EC2 instance

    aws ec2 describe-instances \
    --instance-ids $AWS_EC2_INSTANCE \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
    --output text

### 19. öffentliche IP in eine Variable speichern

#### Get the public ip address of your instance

    AWS_PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $AWS_EC2_INSTANCE \
    --query 'Reservations[*].Instances[*].[PublicIpAddress]' \
    --output text)

#### output ip

    echo $AWS_EC2_PUBLIC_IP

### 20. Herstellen einer SSH-Verbindung zur EC2-Instanz

#### SSH into the EC2 instance

    ssh -i DevOpsKeyPair.pem ec2-user@$AWS_PUBLIC_IP


#### Zum Testen, ob nichts schief gelaufen ist, öffnen des Browser auf dem Hostrechner und geben folgende URL ein. öffentliche Ip der EC2-Instanz/wordpress/wp-admin/install.php

### [Schritt für Schritt Anleitung - zum Nachlesen](https://dev.to/mkabumattar/how-to-create-an-aws-ec2-instance-using-aws-cli-32ek)

1. Sicherheitsgruppe von cloud9 Frankfurt ipv4 http hinzufügen 0.0.0.0/0
2. docker run --name some-wordpress -p 8080:80 -d wordpress
3. 


## Flask App erstellen

[Turorial](https://www.youtube.com/watch?v=0irsbYywM_U)
[Anleitung](https://code.tutsplus.com/de/tutorials/creating-a-web-app-from-scratch-using-python-flask-and-mysql--cms-22972)