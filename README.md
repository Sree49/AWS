# AWS


Installing Jenkins: 

Install ubuntu ec2 instance (jenkins-master instance). 

sudo apt update \
sudo apt install fontconfig openjdk-21-jre \
java -version

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
sudo cat id_ed25519.pub 

Copy this data to Jenkins Agent: \
cd .ssh/   \
ls \
sudo vi authourized_keys \
add pub key data (shift,rightclick to paste) 

In Jenkins URL: Go to Settings-> Nodes -> Built-in Node (make executors zero) \
Add new Node - Jenkins-Agent -> Executors-2 -> root dir- /home/ubuntu -> Launch agent via SSH -> copy master private ip, private key, username-ubuntu -> Build now.

Install Plugins in Jenkins: Maven Integration, Pipeline Maven Integration, Eclipse Temurin installer.

Jenkins-> Tools -> Add maven and jdk versions to install automatically.

Intergrate Sonarqube: 

Install new ubuntu server for sonarqube:
$ sudo apt update
    $ sudo apt upgrade
## Add PostgresSQL repository
    $ sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    $ wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null
## Install PostgreSQL
    $ sudo apt update
    $ sudo apt-get -y install postgresql postgresql-contrib
    $ sudo systemctl enable postgresql
## Create Database for Sonarqube
    $ sudo passwd postgres
    $ su - postgres
    $ createuser sonar
    $ psql 
    $ ALTER USER sonar WITH ENCRYPTED password 'sonar';
    $ CREATE DATABASE sonarqube OWNER sonar;
    $ grant all privileges on DATABASE sonarqube to sonar;
    $ \q
    $ exit
## Add Adoptium repository
    $ sudo bash
    $ wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
    $ echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
 ## Install Java 17
    $ apt update
    $ apt install temurin-17-jdk
    $ update-alternatives --config java
    $ /usr/bin/java --version
    $ exit 
## Linux Kernel Tuning
   # Increase Limits
    $ sudo vim /etc/security/limits.conf
    //Paste the below values at the bottom of the file
    sonarqube   -   nofile   65536
    sonarqube   -   nproc    4096

    # Increase Mapped Memory Regions
    sudo vim /etc/sysctl.conf
    //Paste the below values at the bottom of the file
    vm.max_map_count = 262144

#### Sonarqube Installation ####
## Download and Extract
    $ sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
    $ sudo apt install unzip
    $ sudo unzip sonarqube-9.9.0.65466.zip -d /opt
    $ sudo mv /opt/sonarqube-9.9.0.65466 /opt/sonarqube
## Create user and set permissions
     $ sudo groupadd sonar
     $ sudo useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar
     $ sudo chown sonar:sonar /opt/sonarqube -R
## Update Sonarqube properties with DB credentials
     $ sudo vim /opt/sonarqube/conf/sonar.properties
     //Find and replace the below values, you might need to add the sonar.jdbc.url
     sonar.jdbc.username=sonar
     sonar.jdbc.password=sonar
     sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
## Create service for Sonarqube
$ sudo vim /etc/systemd/system/sonar.service
//Paste the below into the file
     [Unit]
     Description=SonarQube service
     After=syslog.target network.target

     [Service]
     Type=forking

     ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
     ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

     User=sonar
     Group=sonar
     Restart=always

     LimitNOFILE=65536
     LimitNPROC=4096

     [Install]
     WantedBy=multi-user.target

## Start Sonarqube and Enable service
     $ sudo systemctl start sonar
     $ sudo systemctl enable sonar
     $ sudo systemctl status sonar

## Watch log files and monitor for startup
     $ sudo tail -f /opt/sonarqube/logs/sonar.log


open 9000 port on server.

In Sonarqube portal-> Administration->Security- > create token.

In Jenkins Portal-> Add sonar credential as secret text.

Install Sonarqube Scanner, Sonar Quality Gates, Quality gates in Jenkins Plugins.

Jenkins-Portal -> Tools -> Check Install sonarqube automatically and save.

Jenkins Portal-> System -> Add Sonarqube connection - server url, token select and save.

Create webhook in sonarqube. Administration-> Webhook -> give http://<jenkins-ip>:8080/sonarqube-webhook/ and create.
Build Jenkins job.


Docker Setup:

Create Jenkins credential to store docker username and secret.


Kubernetes Setup:

Install new ubuntu ec2 for kubernetes setup:

## Installing kubectl
Refer--https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
$ sudo su
$ curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
$ ll , $ chmod +x ./kubectl  //Gave executable permisions
$ mv kubectl /bin   //Because all our executable files are in /bin
$ kubectl version --output=yaml

## Installing  eksctl
Refer---https://github.com/eksctl-io/eksctl/blob/main/README.md#installation
$ curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
$ cd /tmp
$ ll
$ sudo mv /tmp/eksctl /bin
$ eksctl version

Add new IAM role and provide administrator access and attach IAM role to ec2.

## Setup Kubernetes using eksctl
Refer--https://github.com/aws-samples/eks-workshop/issues/734
$ eksctl create cluster --name virtualtechbox-cluster \
--region ap-southeast-2 \
--node-type m7i-flex.large \
--nodes 3 \

$ kubectl get nodes


Argo cd installation:

1 ) First, create a namespace
    $ kubectl create namespace argocd

2 ) Next, let's apply the yaml configuration files for ArgoCd
    $ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

3 ) Now we can view the pods created in the ArgoCD namespace.
    $ kubectl get pods -n argocd

4 ) To interact with the API Server we need to deploy the CLI:
    $ curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64
    $ chmod +x /usr/local/bin/argocd

5 ) Expose argocd-server
    $ kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

6 ) Wait about 2 minutes for the LoadBalancer creation
    $ kubectl get svc -n argocd

7 ) Get pasword and decode it.
    $ kubectl get secret argocd-initial-admin-secret -n argocd -o yaml
    $ echo WXVpLUg2LWxoWjRkSHFmSA== | base64 --decode

## Add EKS Cluster to ArgoCD
9 ) login to ArgoCD from CLI
    $ argocd login a0acc69b224ef4938a32a5ee3a2c4cb4-533394942.ap-southeast-2.elb.amazonaws.com --username admin

10 ) 
     $ argocd cluster list

11 ) Below command will show the EKS cluster
     $ kubectl config get-contexts

12 ) Add above EKS cluster to ArgoCD with below command
     $ argocd cluster add i-00d944fa97a6e6ba7@virtualtechbox-cluster1.ap-southeast-2.eksctl.io  --name virtualtechbox-eks-cluster


13 ) $ kubectl get svc

Argocd url: http://a0acc69b224ef4938a32a5ee3a2c4cb4-533394942.ap-southeast-2.elb.amazonaws.com/

Add Github repo in settings.

Copy kubernetes manifest files to github repo.

Add Application -> select repo, cluster and namespace and create. App will be created and resources will be deployed.

Integrate CI/CD to Jenkins Pipeline:

In Job edit This project is parameterized and add IMAGE_TAG, Trigger builds remotely (e.g., from scripts) enter gitopstoken.

Create jenkins api token-> Account-> Security-> API Token-> JENKINS_API_TOKEN

Copy this token to Jenkins Credential.

Add environment variable -JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN") in jenkinsfile.




============================================================= Cleanup =============================================================
$ kubectl get all
$ kubectl delete deployment.apps/virtualtechbox-regapp       //it will delete the deployment
$ kubectl delete service/virtualtechbox-service              //it will delete the service
$ eksctl delete cluster virtualtechbox --region ap-south-1     OR    eksctl delete cluster --region=ap-south-1 --name=virtualtechbox-cluster      //it will delete the EKS cluster








