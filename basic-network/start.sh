#!/bin/bash
set -ev


export MSYS_NO_PATHCONV=1 #환경변수 설정 

docker-compose -f docker-compose.yaml down #이전 도커 컨테이너 실행중일경우, 컨테이너 다운 
docker-compose -f docker-compose.yaml up -d orderer.cnrlpub.com peer0.sales1.cnrlpub.com peer1.sales1.cnrlpub.com peer0.customer.cnrlpub.com peer1.customer.cnrlpub.com cli #도커파일 실행 


# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
sleep ${FABRIC_START_TIMEOUT}

# channelsales1 채널 생성 
docker exec cli peer channel create -o orderer.cnrlpub.com:7050 -c channelsales1 -f /etc/hyperledger/configtx/channel1.tx

# sales1조직의 peer0 노드를 channelsales1 채널에 가입 시킨후 앵커 피어 지정 업데이트 
docker exec cli peer channel join -b channelsales1.block
docker exec cli peer channel update -o orderer.cnrlpub.com:7050 -c channelsales1 -f /etc/hyperledger/configtx/Sales1Organchors.tx

# sales1조직의 peer1 노드를 channelsales1 채널에 가입 
docker exec -e "CORE_PEER_ADDRESS=peer1.sales1.cnrlpub.com:7051" cli peer channel join -b channelsales1.block

# customer 조직 환경변수 설정 , peer0 channelsales1 에 가입 , 앵커 피어 지정 업데이트 
docker exec -e "CORE_PEER_LOCALMSPID=CustomerOrg" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.cnrlpub.com/users/Admin@customer.cnrlpub.com/msp" -e "CORE_PEER_ADDRESS=peer0.customer.cnrlpub.com:7051" cli peer channel join -b channelsales1.block
docker exec -e "CORE_PEER_LOCALMSPID=CustomerOrg" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.cnrlpub.com/users/Admin@customer.cnrlpub.com/msp" -e "CORE_PEER_ADDRESS=peer0.customer.cnrlpub.com:7051" cli peer channel update -o orderer.cnrlpub.com:7050 -c channelsales1 -f /etc/hyperledger/configtx/CustomerOrganchors.tx

# customer 조직 환경변수 설정, peer1 channelsales1 에 가입 
docker exec -e "CORE_PEER_LOCALMSPID=CustomerOrg" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/customer.cnrlpub.com/users/Admin@customer.cnrlpub.com/msp" -e "CORE_PEER_ADDRESS=peer1.customer.cnrlpub.com:7051" cli peer channel join -b channelsales1.block