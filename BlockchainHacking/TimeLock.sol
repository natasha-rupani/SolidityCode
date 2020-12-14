// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

contract TimeLock {
    uint256 public unlockTime;
    
    constructor() public payable {
        unlockTime = block.timestamp + (365 * 86400); // 1 year
    }
    
    function increaseUnlockTime(uint256 numSeconds) public {
        unlockTime += numSeconds;
    }
    
    function claim() public payable {
        require(msg.value == 1 ether, "please send along 1 ETH to claim");
        if (block.timestamp >= unlockTime) {
            msg.sender.transfer(address(this).balance);
        }
    }
}