curl -s -X POST   http://localhost:4001/registerUser   -H "content-type: application/json"   -d '{
  "orgname":"org1"
}'
curl -s -X POST   http://localhost:4001/registerUser   -H "content-type: application/json"   -d '{
  "orgname":"org3"
}'


curl -s -X POST   http://localhost:4001/channels   -H "content-type: application/json"   -d '{
  "orgname":"org1",
  "channelName":"mycc2",
  "channelConfigPath":"../artifacts/channel-artifacts/mycc2.tx"
}'

curl -s -X POST   http://localhost:4001/joinchannel   -H "content-type: application/json"   -d '{
  "orgname":"org1",
  "channelName":"mycc2"
}'

curl -s -X POST   http://localhost:4001/joinchannel   -H "content-type: application/json"   -d '{
  "orgname":"org3",
  "channelName":"mycc2"
}'

curl -s -X POST   http://localhost:4001/chaincodes   -H "content-type: application/json"   -d '{
  "orgname":"org1",
  "chaincodeId":"fabcar",
  "chaincodePath":"chaincodes/fabcar/",
  "chaincodeVersion":"v1.0",
  "chaincodeType":"golang"
}'
curl -s -X POST   http://localhost:4001/chaincodes   -H "content-type: application/json"   -d '{
  "orgname":"org3",
  "chaincodeId":"fabcar",
  "chaincodePath":"chaincodes/fabcar/",
  "chaincodeVersion":"v1.0",
  "chaincodeType":"golang"
}'
initchaincodes
upgradeChainCode
curl -s -X POST   http://localhost:4001/initchaincodes   -H "content-type: application/json"   -d '{
  "orgname":"org1",
  "channelName":"mycc2",
  "chaincodeId":"fabcar",
  "chaincodeVersion":"v1.0",
  "chaincodeType":"golang",
  "args":[]
}'

curl -s -X POST   http://localhost:4001/invokeChainCode   -H "content-type: application/json"   -d '{
  "username":"org1",
  "orgname":"org1",
  "channelName":"mycc2",
  "chaincodeId":"fabcar",
  "chaincodeVersion":"v1.0",
  "chaincodeType":"golang",
  "fcn": ["",""]
  "args":[]
}'

curl -s -X POST   http://localhost:4001/queryChainCode   -H "content-type: application/json"   -d '{
  "username":"org1",
  "orgname":"org1",
  "channelName":"mycc2",
  "chaincodeId":"fabcar",
  "fcn": ["",""]
  "args":[]
}'
