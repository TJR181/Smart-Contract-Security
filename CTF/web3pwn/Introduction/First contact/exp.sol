pragma solidity 0.8.19;


contract IFirstContact {
    bool public contacted = false;

    function contact() external {
        contacted = true; 
    }
}


contract Exploit {
    address target;
    constructor(address donatorAddress) {
        target = donatorAddress;
    }

    function attack() external {
        IFirstContact ifc = IFirstContact(target);
        ifc.contact();
    }
}
