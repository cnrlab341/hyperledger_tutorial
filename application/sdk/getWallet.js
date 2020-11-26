'use strict';

const { FileSystemWallet, Gateway } = require('fabric-network'); //fabric-network 라이브러리 가지고 옴 
const path = require('path');

const ccpPath = path.resolve(__dirname, '..', 'connection.json'); //connection.json 파일 불러옴 

async function main() {
    try {

        const walletPath = path.join(process.cwd(), '..', 'wallet'); //인증서 위치 반환 
        const wallet = new FileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        const userExists = await wallet.exists('user1'); //user1이 등록됐는지 확인 
        if (!userExists) {
            console.log('An identity for the user "user1" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        const gateway = new Gateway();
        await gateway.connect(ccpPath, { wallet, identity: 'user1', discovery: { enabled: true, asLocalhost: true } }); //user1으로 접속

        const network = await gateway.getNetwork('channelsales1'); //channelsales1 채널 접속 

        const contract = network.getContract('music-cc'); //체인코드 불러옴 

        var walletid = process.argv[2];

        const result = await contract.evaluateTransaction('getWallet', walletid); //체인코드 getWallet 함수 호출, Invoke, 체인코드 결과 저장 
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);

    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        process.exit(1);
    }
}

main();
