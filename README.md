# utop
# Deploy Hyperledger Fabric Network


## SETUP ENVIRONMENT  
#### If it's Ubuntu you'll need to install the build-essential package
```shell
sudo apt-get install build-essential
```
#### 1. Install Docker CE, Docker-compose
```shell
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce

docker --version #check if install ok and docker version
```
To run docker as non-root
```
sudo groupadd docker
sudo usermod -aG docker $USER
sudo reboot #reboot to take effect

```
Install nodejs
```
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version #check nodejs version
```
Install docker-compose
```
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose -v
```
#### 2. Download GO and setup environment
```shell
wget https://dl.google.com/go/go1.10.2.linux-amd64.tar.gz  #ex: version 1.10.2
tar -C $HOME -xzf go1.10.2.linux-amd64.tar.gz
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$GOPATH/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
go version #check if setup ok
```
#### 3. Download HL fabric binary
```shell
cd $HOME 
curl -sSL http://bit.ly/2ysbOFE | bash -s 1.4.1
echo 'export PATH=$HOME/fabric-samples/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```
#### 4. Install zip, unzip
```
sudo apt-get install zip
sudo apt-get install unzip
```
#### 5. Install PM2
```
sudo npm install -g pm2

sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu  #Auto start when start Ubuntu 
 ```

## PULL SOURCE  
```shell
git clone https://gitlab.com/akachain/akc-network.git
git checkout akc-prod
```

## INIT, JOIN DOCKER SWARM 

##### IN NODE 1
```shell
docker swarm init
docker swarm join-token manager
```

###### Success screen
```
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-0orgd11b3kmiip9gjqydi7spuonkpjrxvut00b9076qqwleip6-e1fvq0bnwxf67ogyhm4rjr60t 10.0.82.225:2377
Copy this token to use later
```
###### Create Docker swarm network
```
docker network create --attachable --driver overlay akc-net 
#create network named akc-net. replace it by any names you like
```

#### IN NODE 1, 2, 3
```shell
docker swarm join --token 'the_token_from_above' 
# ex: docker swarm join --token SWMTKN-1-3adyhli2n28k373fh0jcpo0f7f7doh03han0efnjy4rhv72w49-0iz12fb7ot0gacvp5aqvuave3 94.177.190.188:2377
```

## GENERATE CERTIFICATES 

#### Clean old certificates if exist
```shell
  cd $HOME/akc-network
  ./runFabric.sh clean
```
#### Edit config ip of org, orderer in ./runFabric.sh
```shell
Ex: 
CLI_TIMEOUT=10 #timeout duration - the duration the CLI should wait for a response from another container before giving up
CLI_DELAY=3 #default for delay
CHANNEL_NAME=("loyalstarchannel" "ftelchannel") # channel name defaults to "loyalstarchannel"
EXPMODE="Generating certs and genesis block for"
TOTALORG=4
ORGNAMES=("loyalstar" "familymart" "frt" "ftel")
ORGDOMAINS=("loyalstar.com" "familymart.com" "frt.com" "ftel.com")
ORGMSPS=("loyalstarMSP" "familymartMSP" "frtMSP" "ftelMSP")

CHAINCODEID=("loyalstar_cc" "ftel_cc")
CHAINCODEVERSION=("v1.0" "v1.0")

ORDERERIP="54.95.32.199"
ORGIPS=("54.95.72.122" "18.179.165.147" "18.179.96.163" "54.95.32.199")
CAIPS=("54.95.72.122" "18.179.165.147" "18.179.96.163" "54.95.32.199")

CAPORTS=("7054" "8054" "9054" "10054")

PEER0_DB_PORT_ORG=("5984" "7984" "9984" "11984")
PEER1_DB_PORT_ORG=("6984" "8984" "10984" "12984")

PEER0_PORT0_ORG=("7051" "8051" "9051" "10051")
PEER0_PORT1_ORG=("7053" "8053" "9053" "10053")

PEER1_PORT0_ORG=("7056" "8056" "9056" "10056")
PEER1_PORT1_ORG=("7058" "8058" "9058" "10058")
```

#### Generate certificates 
```shell
  cd $HOME/akc-network
  ./runFabric generate
```

#### Copy artifact
```shell
  cd $HOME/akc-network
  rm -rf ../akc-admin/artifacts
  rm -rf ../akc-admin/fabric-client-kv-*
  cp -R artifacts/ ../akc-admin
  

  rm -rf ../akc-dapp/artifacts
  rm -rf ../akc-dapp/fabric-client-kv-*
  cp -R artifacts/ ../akc-dapp
```

#### Zip folder akc-admin, akc-network, akc-dapp
```shell
  cd $HOME
  zip -r akachain.zip akc-admin akc-network akc-dapp
```

#### Copy akachain.zip to all nodes

#### Unzip akachain.zip in all nodes
```shell
cd $HOME
unzip akachain.zip
```

## INSTALL ZOOKEEPER    
```shell
  cd $HOME/akc-network
```
#### Run this command in node 1 to start zookeeper0:
```shell

```
#### Run this command in node 2 to start zookeeper1:
```shell
./runFabric.sh run zookeeper 1

```
#### Run this command in node 3 to start zookeeper2:
```shell
./runFabric.sh run zookeeper 2

```
## INSTALL kafka  
```shell
  cd $HOME/akc-network
```
#### Run this command in node 1 to start kafka0:
```shell
./runFabric.sh run kafka 0

```

#### Run this command in node 2 to start kafka1:
```shell
./runFabric.sh run kafka 1

```

#### Run this command in node 2 to start kafka2:
```shell
./runFabric.sh run kafka 2

```

## INSTALL orderer
```shell
  cd $HOME/akc-network
```
#### Run this command in node 4 to start orderer:
```shell
./runFabric.sh run orderer

```
## INSTALL CA 
```shell
  cd $HOME/akc-network
```
#### Run this command in node 1 to start CA AKC:
```shell
./runFabric.sh run ca 0

```
#### Run this command in node 2 to start CA AIA:
```shell
./runFabric.sh run ca 1

```
#### Run this command in node 3 to start CA UTOP:
```shell
./runFabric.sh run ca 2

```
#### Run this command in node 4 to start CA FRT:
```shell
./runFabric.sh run ca 3

```


## ADD affiliation in 4 CA  
```shell
  cd $HOME/akc-network
```
#### Run this command in node 1 to start CA AKC:
```shell
./runFabric.sh run configCA 0

```
#### Result:
```shell
Successfully added affiliation: akc.department1
Affiliation list:
affiliation: .
   affiliation: org1
      affiliation: org1.department1
      affiliation: org1.department2
   affiliation: akc
      affiliation: akc.department1
   affiliation: org2
      affiliation: org2.department1
```
#### Run this command in node 2 to start CA AIA:
./runFabric.sh run configCA 1

```shell
	Result:
Successfully added affiliation: aia.department1
Affiliation list:
affiliation: .
   affiliation: org1
      affiliation: org1.department2
      affiliation: org1.department1
   affiliation: aia
      affiliation: aia.department1
   affiliation: org2
      affiliation: org2.department1
```

#### Run this command in node 3 to start CA UTOP:
./runFabric.sh run configCA 2

```shell
	Result:
Successfully added affiliation: utop.department1
Affiliation list:
affiliation: .
   affiliation: org1
      affiliation: org1.department1
      affiliation: org1.department2
   affiliation: org2
      affiliation: org2.department1
   affiliation: utop
      affiliation: utop.department1
```

#### Run this command in node 4 to start CA FRT:
./runFabric.sh run configCA 3

```shell
	Result:
Successfully added affiliation: frt.department1
Affiliation list:
affiliation: .
   affiliation: frt
      affiliation: frt.department1
   affiliation: org1
      affiliation: org1.department1
      affiliation: org1.department2
   affiliation: org2
      affiliation: org2.department1
```

```shell
  cd $HOME/akc-network
```
## INSTALL akc Org

```shell
./runFabric.sh run peer 0 0

./runFabric.sh run peer 0 1

docker run -d --restart=always -it --network="akc-net" \
     --name network-akc-peer2.akc.com-db \
     --expose 5984 -p 15984:5984 \
     -v /home/ubuntu/data:/opt/couchdb/data \
     -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=XXXXX \
     -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=akc-net hyperledger/fabric-couchdb

docker run -d --restart=always -it --network="akc-net" \
        --name network-akc-peer2.akc.com \
        --expose 7051 --expose 7053 -p 12051:7051 \
        -p 12053:7053 -e CORE_LEDGER_STATE_STATEDATABASE=CouchDB \
        -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=network-akc-peer2.akc.com-db:5984 \
        -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=admin -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=XXXXXX \
        -e CORE_PEER_ADDRESSAUTODETECT=true -e CORE_LOGGING_LEVEL=DEBUG \
        -e CORE_PEER_NETWORKID=network-akc-peer2.akc.com \
        -e CORE_NEXT=true -e CORE_PEER_ENDORSER_ENABLED=true \
        -e CORE_PEER_ID=network-akc-peer2.akc.com \
        -e CORE_PEER_PROFILE_ENABLED=true -e CORE_PEER_COMMITTER_LEDGER_ORDERER=network-akc.orderer.com:7050 \
        -e CORE_PEER_GOSSIP_IGNORESECURITY=true -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=akc-net \
        -e CORE_PEER_GOSSIP_EXTERNALENDPOINT=network-akc-peer2.akc.com:7051 \
        -e CORE_PEER_TLS_ENABLED=true \
        -e CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt \
        -e CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key \
        -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt \
        -e CORE_PEER_GOSSIP_USELEADERELECTION=true -e CORE_PEER_GOSSIP_ORGLEADER=false \
        -e CORE_PEER_GOSSIP_SKIPHANDSHAKE=true -e CORE_PEER_LOCALMSPID=akcMSP \
        -e CORE_VM_DOCKER_HOSTCONFIG_MEMORY=268435456 -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(pwd)/artifacts/crypto-config/peerOrganizations/akc.com/peers/peer2.akc.com/msp:/etc/hyperledger/fabric/msp  \
        -v $(pwd)/artifacts/crypto-config/peerOrganizations/akc.com/peers/peer2.akc.com/tls:/etc/hyperledger/fabric/tls  \
        -w /opt/gopath/src/github.com/hyperledger/fabric/peer hyperledger/fabric-peer peer node start

docker run -d --restart=always -it --network="akc-net" \
     --name network-akc-peer3.akc.com-db \
     --expose 5984 -p 16984:5984 \
     -v /home/ubuntu/data:/opt/couchdb/data \
     -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=XXXXXX \
     -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=akc-net hyperledger/fabric-couchdb

docker run -d --restart=always -it --network="akc-net" \
        --name network-akc-peer3.akc.com \
        --expose 7051 --expose 7053 -p 12056:7051 \
        -p 12058:7053 -e CORE_LEDGER_STATE_STATEDATABASE=CouchDB \
        -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=network-akc-peer3.akc.com-db:5984 \
        -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=admin -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=XXXXXX \
        -e CORE_PEER_ADDRESSAUTODETECT=true -e CORE_LOGGING_LEVEL=DEBUG \
        -e CORE_PEER_NETWORKID=network-akc-peer3.akc.com \
        -e CORE_NEXT=true -e CORE_PEER_ENDORSER_ENABLED=true \
        -e CORE_PEER_ID=network-akc-peer3.akc.com \
        -e CORE_PEER_PROFILE_ENABLED=true -e CORE_PEER_COMMITTER_LEDGER_ORDERER=network-akc.orderer.com:7050 \
        -e CORE_PEER_GOSSIP_IGNORESECURITY=true -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=akc-net \
        -e CORE_PEER_GOSSIP_EXTERNALENDPOINT=network-akc-peer3.akc.com:7051 \
        -e CORE_PEER_TLS_ENABLED=true \
        -e CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt \
        -e CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key \
        -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt \
        -e CORE_PEER_GOSSIP_USELEADERELECTION=true -e CORE_PEER_GOSSIP_ORGLEADER=false \
        -e CORE_PEER_GOSSIP_SKIPHANDSHAKE=true -e CORE_PEER_LOCALMSPID=akcMSP \
        -e CORE_VM_DOCKER_HOSTCONFIG_MEMORY=268435456 -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(pwd)/artifacts/crypto-config/peerOrganizations/akc.com/peers/peer3.akc.com/msp:/etc/hyperledger/fabric/msp  \
        -v $(pwd)/artifacts/crypto-config/peerOrganizations/akc.com/peers/peer3.akc.com/tls:/etc/hyperledger/fabric/tls  \
        -w /opt/gopath/src/github.com/hyperledger/fabric/peer hyperledger/fabric-peer peer node start
```
## INSTALL aia Org
```shell
./runFabric.sh run peer 1 0

./runFabric.sh run peer 1 1


```
## INSTALL utop Org
```shell
./runFabric.sh run peer 2 0

./runFabric.sh run peer 2 1

```
## INSTALL frt Org
```shell
./runFabric.sh run peer 3 0

./runFabric.sh run peer 3 1

```

## RUN ADMIN APP & INIT NETWORK

##### IN ALL NODES
```shell
cd $HOME/akc-admin
rm -rf fabric-client-kv-*
node server.js

```
###### Screen EX:
```
============== node modules installed already =============

[INFO] utop-service - ****************** SERVER STARTED ************************
[INFO] utop-service - ***************  http://localhost:4001  ******************
```


