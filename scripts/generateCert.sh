function generateConfigFiles () {
  # OPTS="-i"
  cp -f ../template/cryptogen-template.yaml cryptogen.yaml
  cp -f ../template/configtx-template.yaml configtx.yaml

  max=`expr $TOTALORG - 1`
  for i in `seq 0 $max`
  do 
    current_idx=`expr $i + 1`
    sed $OPTS "s/ORG${current_idx}NAME/${ORGNAMES[i]}/g" cryptogen.yaml
    sed $OPTS "s/ORG${current_idx}MSP/${ORGMSPS[i]}/g" cryptogen.yaml
    sed $OPTS "s/ORG${current_idx}DOMAIN/${ORGDOMAINS[i]}/g" cryptogen.yaml
    sed $OPTS "s/ORG${current_idx}NAME/${ORGNAMES[i]}/g" configtx.yaml
    sed $OPTS "s/ORG${current_idx}MSP/${ORGMSPS[i]}/g" configtx.yaml
    sed $OPTS "s/ORG${current_idx}DOMAIN/${ORGDOMAINS[i]}/g" configtx.yaml
    sed $OPTS "s/REQUESTCHANNEL/${CHANNEL_NAME[0]}/g" configtx.yaml
  done 
}

function generateCerts () {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi 
  
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"
  set -x 
  if [ -d "crypto-config" ]; then 
    echo "old crypto-config folder found. deleting"
    rm -rf crypto-config
  fi
  cryptogen generate --config=./cryptogen.yaml
  set +x 
}

function generateCerts () {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi 
  
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"
  set -x 
  if [ -d "crypto-config" ]; then 
    echo "old crypto-config folder found. deleting"
    rm -rf crypto-config
  fi
  cryptogen generate --config=./cryptogen.yaml
  set +x 
}

function generateChannelArtifacts () {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi
  echo pwd = $PWD

  if [ -d "channel-artifacts" ]; then
    echo "Removing old channel artifacts..."
    rm -rf channel-artifacts/*
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"

  set -x
  export FABRIC_CFG_PATH=$PWD
  configtxgen -profile AKCOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi

  max=`expr ${#CHANNEL_NAME[@]} - 1`
  for i in `seq 0 $max`
  do
    echo "##########################################################"
    echo "### Generating channel configuration transaction '${CHANNEL_NAME[i]}.tx' ###"
    echo "#################################################################"
    set -x
    
    configtxgen -profile ${CHANNEL_NAME[i]} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME[i]}.tx -channelID ${CHANNEL_NAME[i]}
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate channel configuration transaction..."
      exit 1
    fi
  done

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update   ##########"
  echo "#################################################################"
  set -x

  # OPTS="-i"

  max=`expr $TOTALORG - 1`
  for i in `seq 0 $max`
  do 
    configtxgen -profile ${CHANNEL_NAME} -outputAnchorPeersUpdate ./channel-artifacts/${ORGNAMES[i]}anchors.tx -channelID $CHANNEL_NAME -asOrg ${ORGMSPS[i]}
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate anchor peer update for ${ORGNAMES[i]}MSP..."
      exit 1
    fi
  done 

}

function generateOrgsYamlFiles () {
  # OPTS="-i"
  max=`expr $TOTALORG - 1`
  for i in `seq 0 $max`
  do 
    cp -f ../template/org-template.yaml ${ORGNAMES[i]}.yaml
    sed $OPTS "s/ORGNAME/${ORGNAMES[i]}/g" ${ORGNAMES[i]}.yaml
  done 
}

function replacePrivateKey () {
  # OPTS="-i"
  cp -f ../template/network-config-template.yaml network-config.yaml
  CURRENT_DIR=$PWD
  set -x
  sed $OPTS "s/CURRENT_USER/${USER}/g" network-config.yaml
  set +x
  max=`expr $TOTALORG - 1`
  for i in `seq 0 $max`
  do 
    set -x
    current_idx=`expr $i + 1`

    cd crypto-config/peerOrganizations/${ORGDOMAINS[i]}/users/Admin@${ORGDOMAINS[i]}/msp/keystore/
    PRIV_KEY=$(ls *_sk)
    cd "$CURRENT_DIR"
    sed $OPTS "s/ADMIN_ORG${current_idx}_PRIVATE_KEY/${PRIV_KEY}/g" network-config.yaml

    sed $OPTS "s/ORG${current_idx}NAME/${ORGNAMES[i]}/g" network-config.yaml
    sed $OPTS "s/ORG${current_idx}MSP/${ORGMSPS[i]}/g" network-config.yaml
    sed $OPTS "s/ORG${current_idx}DOMAIN/${ORGDOMAINS[i]}/g" network-config.yaml
    sed $OPTS "s/REQUESTCHANNEL/${CHANNEL_NAME[0]}/g" network-config.yaml
    set +x
  done 

}

function generate () {
  CURRENT_DIR_GENERATE=$PWD
  if [ ! -d artifacts ]; then 
    echo "artifacts folder not found. exiting"
    exit 1
  fi
  cd artifacts
  if [ ! -d channel-artifacts ]; then 
    mkdir channel-artifacts
  fi

  generateConfigFiles
  generateCerts
  generateChannelArtifacts
  replacePrivateKey
  generateOrgsYamlFiles
  cd $CURRENT_DIR_GENERATE
  echo $CURRENT_DIR_GENERATE
  echo $PWD
}

ARCH=`uname -s | grep Darwin`
if [ "$ARCH" == "Darwin" ]; then
  OPTS="-it"
else
  OPTS="-i"
fi

cd /shared
source /shared/scripts/env.sh
generate