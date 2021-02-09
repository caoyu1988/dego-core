pragma solidity ^0.5.0;

import "./NFTHelper.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC721/ERC721.sol";

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC721/ERC721Metadata.sol";

contract NFTOwnership is NFTHelper,ERC721{

    mapping (uint => address) nftApprovals;

    // constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {

    // }

    // function setBaseURI(string memory baseUri) public{
    //     _setBaseURI(baseUri);
    // }

    function balanceOf(address _owner) public view returns (uint256 _balance){
        return ownerNFTCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner){
        return NFTToOwner[_tokenId];
    }

    function totalSupply() public view returns (uint256 _totalSupply){
        return uint256(NFTs.length);
    }

    function _transfer(address _from,address _to,uint256 _tokenId) internal{
        ownerNFTCount[_to] = ownerNFTCount[_to].add(1);
        ownerNFTCount[_from] = ownerNFTCount[_from].sub(1);
        NFTToOwner[_tokenId] = _to;
        emit Transfer(_from,_to,_tokenId);
    }

    function transfer(address _to,uint256 _tokenId) public onlyOwnerOf(_tokenId){
        _transfer(msg.sender,_to,_tokenId);
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return nftApprovals[tokenId];
    }

    function transferFrom(address _from,address _to,uint256 _tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(_from,_to,_tokenId);
    }



    function approve (address _to,uint256 _tokenId) public {
        nftApprovals[_tokenId] = _to;
        emit Approval(msg.sender,_to,_tokenId);
    }

    function mint(address _to) internal{
        uint tokenId = _createNFT(_to);
        _mint(_to,tokenId);
    }

    function mint(address _to,uint32 quality,uint32 power) public onlyGovernance{
        uint tokenId = _createNFT(_to,quality,power);
        _mint(_to,tokenId);
    }

    function getPowerById(uint256 _tokenId) public view returns (uint256 _power){
        return NFTs[_tokenId].power;
    }
}