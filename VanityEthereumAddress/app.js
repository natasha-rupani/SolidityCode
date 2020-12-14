const crypto = require('crypto');
const ethUtil= require('ethereumjs-util');

do{
    //privatekey of 32 bytes
const myPrivKey = crypto.randomBytes(32);

//publicKey of 64 bytes
const myPubKey=ethUtil.privateToPublic(myPrivKey);


//creating ehereum address from public key
//Step1: hash it for security
var hashPubKey = ethUtil.keccak256(Buffer.from(myPubKey));


//Step2: take last 20 bytes from the 32 bytes, so that the hash of the whole public key is not exposed
var twentyBytesOfhashPubKey=hashPubKey.slice(12);

//Step3: convert this to hex and suffix 0x
var myEthAddress= '0x'+twentyBytesOfhashPubKey.toString('hex')
console.log(myEthAddress);
if('1234'=== myEthAddress.substring(2,6)){
    console.log("Found the vanity key");
    console.log("Private Key :"+myPrivKey.toString('hex'));
    console.log("Public Key :"+myPubKey.toString('hex'));
    console.log("Hex address: "+myEthAddress);
}

}while(!('1234'=== myEthAddress.substring(2,6)));

