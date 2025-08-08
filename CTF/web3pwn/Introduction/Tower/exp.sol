pragma solidity 0.8.19;

contract ITower {
    enum Level {
        Ground,
        First,
        Second,
        Third,
        Fourth,
        Fifth
    }
    Level level;

    function first() external {
        level = Level.Ground; 
    }

    function second(uint256 val) external {
        require(val == 31337, "not elite");
        level = Level.Second;
    }

    function third(string calldata passphrase) external {
        require(keccak256(bytes(passphrase)) == keccak256("s3cr3tp4ss"), "incorrect passphrase");
        level = Level.Third;
    }

    function fourth() external payable {
        require(msg.value == 1 ether, "not enough funds");
        level = Level.Fourth;
    }

    function fifth() external {
        require(gasleft() > 29000, "not enough gas");
        require(gasleft() < 30000, "too much gas");
        level = Level.Fifth;
    }


    function top() external view returns (bool) {
        return level == Level.Fifth;
    }
}

contract Exploit {
    address target;
    constructor(address donatorAddress) payable {
        target = donatorAddress;
    }

    function attack() external {
        ITower it = ITower(target);
        it.fifth{gas: 29500}();
    }
}
