pragma solidity ^0.5.0;

import "./NFTHelper.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC721/ERC721.sol";

contract NFTOwnership is NFTHelper,ERC721{

    mapping (uint => address) nftApprovals;

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
        //NFTs[_tokenId].author = _to;
        emit Transfer(_from,_to,_tokenId);
    }

    function transfer(address _to,uint256 _tokenId) public onlyOwnerOf(_tokenId){
        _transfer(msg.sender,_to,_tokenId);
    }

    function approve (address _to,uint256 _tokenId) public onlyOwnerOf(_tokenId){
        nftApprovals[_tokenId] = _to;
        emit Approval(msg.sender,_to,_tokenId);
    }

    function mint(address _to) internal {
        uint tokenId = _createNFT(_to);
        _mint(_to,tokenId);
    }
}