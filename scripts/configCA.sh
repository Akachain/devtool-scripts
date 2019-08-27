
cd /shared/artifacts/crypto-config/peerOrganizations/$(echo ${ORGDOMAINS})/ca/
PRIV_ORG_KEY=$(ls *_sk)
echo $PRIV_ORG_KEY
#
rm -rf /shared/artifacts/crypto-config/peerOrganizations/${ORGDOMAINS}/fabric-ca-server
mkdir -p /shared/artifacts/crypto-config/peerOrganizations/${ORGDOMAINS}/fabric-ca-server/
export FABRIC_CA_CLIENT_HOME=/shared/artifacts/crypto-config/peerOrganizations/${ORGDOMAINS}/fabric-ca-server
if [ $TLS_ENABLED == true ]; then
  fabric-ca-client enroll -u https://admin:adminpw@ca.${ORGDOMAINS}:7054 --tls.certfiles /shared/artifacts/crypto-config/peerOrganizations/${ORGDOMAINS}/ca/ca.${ORGDOMAINS}-cert.pem
  echo "Add affiliation ..."
  fabric-ca-client --tls.certfiles /shared/artifacts/crypto-config/peerOrganizations/${ORGDOMAINS}/ca/ca.${ORGDOMAINS}-cert.pem affiliation add ${ORGNAMES}
  fabric-ca-client --tls.certfiles /shared/artifacts/crypto-config/peerOrganizations/${ORGDOMAINS}/ca/ca.${ORGDOMAINS}-cert.pem affiliation add ${ORGNAMES}.department1
  #---- check affiliation list

  echo "Affiliation list:"
  fabric-ca-client --tls.certfiles /shared/artifacts/crypto-config/peerOrganizations/${ORGDOMAINS}/ca/ca.${ORGDOMAINS}-cert.pem affiliation list
  
  set +x
else 
  fabric-ca-client enroll -u http://admin:adminpw@ca.${ORGDOMAINS}:7054
  echo "Add affiliation ..."
  fabric-ca-client affiliation add ${ORGNAMES}
  fabric-ca-client affiliation add ${ORGNAMES}.department1
  #---- check affiliation list

  echo "Affiliation list:"
  fabric-ca-client affiliation list
  
  set +x
fi
