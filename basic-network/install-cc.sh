#!/bin/bash
set -ev

# sales1 조직 peer0노드에서 체인코드 설치 
docker exec cli peer chaincode install -n music-cc -v 1.0 -p chaincode/go
sleep 1
# sales1조직 peer0 노드에서 체인코드 인스턴스화 
docker exec cli peer chaincode instantiate -o orderer.cnrlpub.com:7050 -C channelsales1 -n music-cc -v 1.0 -c '{"Args":[""]}' -P "OR ('Sales1Org.member','CustomerOrg.member')"
sleep 10
# sales1 조직의 peer0 노드에서 체인코드 initWallet 호출 (Invoke)
docker exec cli peer chaincode invoke -o orderer.cnrlpub.com:7050 -C channelsales1 -n music-cc -c '{"function":"initWallet","Args":[""]}'
# sales1 조직의 peer0노드서서 체인코드 setMusic 호출 Invoke 
docker exec cli peer chaincode invoke -o orderer.cnrlpub.com:7050 -C channelsales1 -n music-cc -c '{"function":"setMusic","Args":["Fabric", "Hyper", "20", "1Q2W3E4R"]}'

sleep 3
# query chaincode for channelsales1
docker exec cli peer chaincode query -o orderer.cnrlpub.com:7050 -C channelsales1 -n music-cc -c '{"function":"getAllMusic","Args":[""]}'