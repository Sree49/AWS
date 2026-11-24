# AWS


Installing Jenkins: 

Install ubuntu ec2 instance (jenkins-master instance). sudo apt update. Install Java. \
sudo apt install openjdk-21-jre-headless 

Install jenkins: \
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null 
  
sudo apt update 

sudo apt install jenkins

sudo systemctl enable jenkins

sudo systemctl status jenkins

Install another ec2 instance:

sudo apt update

sudo apt install docker.io

sudo usermod -aG docker $USER

sudo vi /etc/ssh/sshd_config -> Uncomment PubKeyAuthentication, Authorizedkeyfiles in both master and agent instances. sudo service sshd reload

In Master Instance create key: ssh-keygen \
cd ./ssh \
ls \
sudo cat id_ed25519.pub \ 

Copy this data to Jenkins Agent: \
cd .ssh/   \
ls
sudo vi authourized_keys \
add pub key data (shift,rightclick to paste) \

In Jenkins URL: Go to Settings-> Nodes -> Built-in Node (make executors zero) \
Add new Node - Jenkins-Agent -> Executors-2 -> root dir- /home/ubuntu -> Launch agent via SSH -> copy master private ip, private key, username-ubuntu -> Build now.







