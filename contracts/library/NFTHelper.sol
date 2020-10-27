pragma solidity ^0.5.0;

import './NFTFactory.sol';
import './NameFilter.sol';
import "../interface/IERC20.sol";

contract NFTHelper is NFTFactory {

    uint16 public levelUpSuccessProbability = 80;
    uint16 public maxLevel = 35;

    uint256 public levelUpFee = 0.001 ether;
    uint256 public qualityUpFee = 0.01 ether;
    uint256 randNonce = 0;

    IERC20 public XMPT = IERC20(0x20118F8e38494EF7aEAd4B1095Fb0f1F309A4A70);

    modifier abovelLevel(uint32 _nftId,uint _level){

        require(NFTs[_nftId].level >= _level,'Level is not suffcient');
        _;
    }
    modifier onlyOwnerOf(uint _nftId){
        require(msg.sender == NFTToOwner[_nftId],'NFT is not yours');
        _;
    }


    // function levelUp(uint _shovelId,uint _amount) public onlyOwnerOf(_shovelId){
    //     require(_amount  >= upLevelFee,'No enough money');
    //     XMPT.transferFrom(msg.sender,address(this),_amount);
    //     shovels[_shovelId].level ++;
    // }

    function levelUp (uint _nftId) external payable onlyOwnerOf(_nftId){
        require(msg.value >= levelUpFee,'No enough money');
        require(checkLevelUpCondition(_nftId),'Only upgrade to the next quality can be upgraded');
        require(NFTs[_nftId].level != maxLevel,'Upgraded to the highest level');
        uint rand = _randomByModulus(100);
        if(rand < levelUpSuccessProbability - NFTs[_nftId].level * 2){
            NFTs[_nftId].level = uint32(NFTs[_nftId].level.add(1));
        }

    }

    function qualityUp(uint _nftId) external payable onlyOwnerOf(_nftId){
        require(msg.value >= qualityUpFee,'No enough money');
        require(!checkLevelUpCondition(_nftId),'Have not reached the conditions for upgrading quality');
        NFTs[_nftId].quality = uint32(NFTs[_nftId].quality.add(1));
        NFTs[_nftId].level = uint32(NFTs[_nftId].level.add(1));
    }

    function checkLevelUpCondition(uint _nftId) private view returns (bool){
        uint level = NFTs[_nftId].level;
        if(level == 5 || level == 10 || level == 15 || level == 20 || level == 25){
            return false;
        }else{
            return true;
        }
    }


    function changeName(uint _nftId,string calldata _newName) external onlyOwnerOf(_nftId) {
        bytes32 name = NameFilter.nameFilter(_newName);
        NFTs[_nftId].name = name;
    }

    function getNFTByOwner(address _owner) external view returns (uint [] memory){
        uint[] memory result = new uint [] (ownerNFTCount[_owner]);
        uint counter = 0;
        for(uint i = 0;i< NFTs.length; i++){
            if(NFTToOwner[i] == _owner){
                result[counter] = i;
                counter = counter.add(1) ;
            }
        }
        return result;
    }

}