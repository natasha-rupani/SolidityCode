var url="http://127.0.0.1:7545";
var abi=[
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_itemId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_count",
				"type": "uint256"
			}
		],
		"name": "bid",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "register",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "revealWinners",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "payable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "beneficiary",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "items",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "itemId",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "winners",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];

var caller;
var contractInstance;
var contractAddress="0xb8667dCc36f748EEbeaEcA9d75292b62F370a5e6";

var btnRegisterDom=document.querySelector("#registerAsBidder");
var btnBidDom=document.querySelector("#placeBidder");



window.onload=()=>{
	document.querySelector("#registerAsBidder").addEventListener("click",btnRegisterAsBidderOnClick);	
	document.querySelector("#placeBidder").addEventListener("click",btnPlaceBidderOnClick);
	
	var provider = new Web3(new Web3.providers.HttpProvider(url));
	contractInstance= new provider.eth.Contract(abi,contractAddress);
	provider.eth.getAccounts().then(accounts=>{
		caller=accounts[9];
	});

}

function btnRegisterAsBidderOnClick(e){
	e.preventDefault();
	/*contractInstance.methods.register().call().then(val=>{
		console.log("Registered first account");
	});
	*/
	contractInstance.methods.register().send({ from: caller, gas: 500000 }).on('receipt', () => {
        console.log("Registration done");
    })
}

function btnPlaceBidderOnClick(e){
	e.preventDefault();
	let bidItemVal=document.querySelector("#bidItemId").value;
	let bitTokenCountVal= document.querySelector("#bidTokenCount").value;
	contractInstance.methods.bid(bidItemVal,bitTokenCountVal)
	.send({from:caller})
	.on("receipt",()=>{
		console.log("Bid placed!")
		})
	.on("error",message=>{
		console.error(message)
		});

}