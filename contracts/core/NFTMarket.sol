pragma solidity ^0.5.0;

import "../library/NFTOwnership.sol";

contract NFTMarket is NFTOwnership {
    struct sales{
        address payable seller;
        uint price;
    }
    mapping(uint=>sales) public shop;
    uint shopNFTCount;
    uint public tax = 0.001 ether;
    uint public minPrice = 0.01 ether;

    event SaleNFT(uint indexed nftId,address indexed seller);
    event BuyNFT(uint indexed nftId,address indexed buyer,address indexed seller);

    function saleMyNFT(uint _nftId,uint _price)public onlyOwnerOf(_nftId){
        require(_price>=minPrice+tax,'Your price must > minPrice+tax');
        shop[_nftId] = sales(msg.sender,_price);
        shopNFTCount = shopNFTCount.add(1);
        emit SaleNFT(_nftId,msg.sender);
    }
    function buyShopNFT(uint _nftId)public payable{
        require(msg.value >= shop[_nftId].price,'No enough money');
        _transfer(shop[_nftId].seller,msg.sender, _nftId);
        shop[_nftId].seller.transfer(msg.value - tax);
        delete shop[_nftId];
        shopNFTCount = shopNFTCount.sub(1);
        emit BuyNFT(_nftId,msg.sender,shop[_nftId].seller);
    }
    function getShopNFT() external view returns(uint[] memory) {
        uint[] memory result = new uint[](shopNFTCount);
        uint counter = 0;
        for (uint i = 0; i < NFTs.length; i++) {
            if (shop[i].price != 0) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function setTax(uint _value)public onlyGovernance{
        tax = _value;
    }
    function setMinPrice(uint _value)public onlyGovernance{
        minPrice = _value;
    }
}