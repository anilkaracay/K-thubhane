// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "erc721a/contracts/ERC721A.sol";


contract bneDAO {
    struct Offer {
        uint yesVotes;
        uint noVotes;
        uint deadline;
        address to;
        string desc;
        mapping(uint => bool) voters;
        mapping(address => uint) fundedAmaount;
        bool executed;
        uint totalFunded;
    }

    mapping(uint => Offer) public offers;
    uint offerNumber;
    ERC721A daoNFT;

    constructor(address _nft){
        daoNFT = ERC721A(_nft);
    }

    enum Vote {
        yes,
        no
    }

    modifier nftHolderOnly() {
        require(daoNFT.balanceOf(msg.sender)>0,"He is not a DAO member");
        _;
    }

    modifier activeOfferOnly(uint _offerIndex) {
        require(block.timestamp < offers[_offerIndex].deadline, "offer is not active");
        _;
    }
    modifier rejOfferOnly(uint _offerIndex) {
        require(block.timestamp > offers[_offerIndex].deadline, "not yet");
        _;
        require(offers[_offerIndex].yesVotes <= offers[_offerIndex].noVotes, "offer  successful");
    }

    modifier succOfferOnly(uint _offerIndex) {
        require(block.timestamp > offers[_offerIndex].deadline, "not yet");
        _;
        require(offers[_offerIndex].yesVotes > offers[_offerIndex].noVotes, "not much successful");
    }


    function createOffer(address _to, string memory _desc) external nftHolderOnly {
        Offer storage offer = offers[offerNumber];
        offer.to = _to;
        offer.desc = _desc;
        offer.deadline = block.timestamp + 360 minutes;
        offerNumber ++;
    }

    function voteOffer(Vote vote, uint offerIndex, uint[] memory NFTsToVote)external nftHolderOnly activeOfferOnly(offerIndex)   payable {
        uint votePower = NFTsToVote.length;

        require(votePower > 0, "show some NFTs to vote");

        Offer storage offer = offers[offerIndex];

        for(uint i; i<votePower; i++){
            require(daoNFT.ownerOf(NFTsToVote[i]) == msg.sender, "you need to own the NFT");
            require(!offer.voters[NFTsToVote[i]],"this NFT has already used to vote");
            offer.voters[NFTsToVote[i]] = true;
        }

        if(vote == Vote.yes){
            offer.yesVotes += votePower;
            offer.fundedAmaount[msg.sender] += msg.value;
            offer.totalFunded += msg.value;
        }
        if(vote == Vote.no){
            offer.noVotes += votePower;
        }
    }

    function executeOffer(uint offerIndex) external nftHolderOnly succOfferOnly(offerIndex){
        Offer storage offer = offers[offerIndex];

        require(!offer.executed, "offer is already executed");

        offer.executed = true;
        (bool success,) = offer.to.call{value:offer.totalFunded}("");
        require(success, "transfer failed");
    }

    function retrieveFunds(uint offerIndex) external nftHolderOnly rejOfferOnly(offerIndex) {
        Offer storage offer = offers[offerIndex];
        uint funded = offer.fundedAmaount[msg.sender];
        require(funded > 0, "you have not funded");
        offer.fundedAmaount[msg.sender] -= funded;
        (bool success,) = msg.sender.call{value:funded}("");
        require(success, "transfer failed");
    }

    receive() external payable {}

    fallback() external payable {}
}