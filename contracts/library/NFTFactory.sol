pragma solidity ^0.5.0;

import "./Governance.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/math/SafeMath.sol";



contract NFTFactory is Governance{

    uint16 quality_one = 85;
    uint16 quality_two = 95;
    uint256 dnaModulus = 1e16;
    uint256 nonce = 0;


    using SafeMath for uint;
    using SafeMath for uint32;
    using SafeMath for uint256;

    struct NFT {
        bytes32 name;
        uint32 quality;
        uint32 level;
        uint dna;
    }

    NFT [] public NFTs;

    mapping (uint => address) public NFTToOwner;
    mapping (address => uint) public ownerNFTCount;

    event newNFT(uint nftId,uint dna);

    function _generateRandomDNA(address _address) private view returns(uint){
        return uint(keccak256(abi.encodePacked(now,_address,nonce))).mod(dnaModulus);
    }

    function _randomByModulus(uint _modulus) internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,nonce))).mod(_modulus);
    }

    function getRandomQuality() private view returns(uint32){
        uint rand = _randomByModulus(100);
        uint32 quality = 0;
        if(rand < quality_one){
            quality = 1;
        }else if(rand>= quality_one && rand < quality_two){
            quality = 2;
        }else if(rand>=quality_two){
            quality = 3;
        }
        return quality;
    }

    function _createNFT(address _address) internal returns(uint){
        uint dna = _generateRandomDNA(_address);
        uint32 quality = getRandomQuality();
        NFT memory nft = NFT('no name',quality,(quality-1)*5+1,dna);
        NFTs.push(nft) ;
        NFTToOwner[NFTs.length -1] = _address;
        ownerNFTCount[_address] = ownerNFTCount[_address].add(1);
        emit newNFT(NFTs.length.sub(1),dna);
        return NFTs.length;
    }


}