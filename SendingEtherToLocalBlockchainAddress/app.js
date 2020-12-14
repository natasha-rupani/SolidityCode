var ethers=require('ethers');
var provider= new ethers.providers.JsonRpcProvider();

var privateKey = "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d";
var wallet = new ethers.Wallet(privateKey, provider);
console.log("Address: " + wallet.address);

tx = {
  to: "0x30C59d63f5D08Afa84d7896A8fB6C0e5B456D4b8",
  value: ethers.utils.parseEther("1.0")
  //gasLimit: 100000000
  //gasPrice: "0x07f9acf02", 
}
//wallet.signTransaction(tx);
//wallet.connect(provider);

wallet.sendTransaction(tx);
//console.log("New Wallet Balance"+wallet.getBalance());