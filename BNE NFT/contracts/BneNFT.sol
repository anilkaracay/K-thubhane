//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BneNFT is ERC721A, Ownable {

    uint public price = 0.02 ether;
    uint public maxSup = 5000;
    uint public maxMint = 5;
    bytes32 root;
    bool private isSale;
    mapping(address => uint) private mintedCount;
    string private URIPrefix ="bafybeievqtp4drfbx5psvzel6tnq4eoxpwkaufawv7fov3qyf74k4hz7hq/";
    string private URISuffix = ".json";

    constructor() ERC721A ("BNEDAO", "BNE") {

    }

    function _startTokenId() internal override pure returns (uint256){
        return  1;
    }

    function setRoot(bytes32 _root) onlyOwner external {
        root = _root;
    }

    function toggleMint() onlyOwner external {
        isSale = !isSale;
    }

    modifier onlyOrigin {
        require(msg.sender == tx.origin);
        _;
    }

    function publicMint(uint amount) onlyOrigin external payable {
        require(isSale, "mint not active");
        require(msg.value >= amount * price);
        require(totalSupply() + amount <= maxSup);
        require(mintedCount[msg.sender] + amount <= 5);
        mintedCount[msg.sender] += amount;
        _safeMint(msg.sender, amount);
    }

    function setBaseURI(string memory _URIPrefix) external onlyOwner {
        URIPrefix = _URIPrefix;
    }

    function tokenURI(uint tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId), URISuffix)) : '';
    }

    function _baseURI() internal view override returns (string memory) {
        return URIPrefix;
    }

}