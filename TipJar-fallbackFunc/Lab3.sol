pragma solidity ^0.5.0;

contract TipJar {
    address owner;
    
    constructor() public{
        owner=msg.sender;
    }
    
    modifier onlyOwner() {
         require(msg.sender==owner, "Only the owner can do this!");
         _;
    }
    
    function withdrawTips() public onlyOwner{
        msg.sender.transfer(address(this).balance);
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    function() payable external { }
}