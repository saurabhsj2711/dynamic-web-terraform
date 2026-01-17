#!/bin/bash
sudo apt-get update
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<html><h1>Welcome to EC2 instance</h1><p>Hostname : $(hostname -f)</p><p>Instance ID : _INSTANCE_ID_</p></p><p>Private IP : _PRIVATE_IP_</p></html>" | sudo tee /var/www/html/index.html
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
sed -i "s/_INSTANCE_ID_/$INSTANCE_ID/g" /var/www/html/index.html
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://$IMDS_IP/latest/meta-data/local-ipv4)
sed -i "s/_PRIVATE_IP_/$INSTANCE_ID/g" /var/www/html/index.html
