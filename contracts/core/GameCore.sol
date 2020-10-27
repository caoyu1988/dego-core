pragma solidity ^0.5.0;

import "./Lottery.sol";
import "./NFTGame.sol";

contract GameCore is NFTGame{
    string public constant name = "XiaMiPool NFT";
    string public constant symbol = "XMNFT";

    function() external payable {
    }


    function checkBalance() external view onlyGovernance returns(uint) {
        return address(this).balance;
    }


    function setPlayFee(uint _fee) external onlyGovernance{
        playFee = _fee;
    }

    function setWinnerXMPTRewards(uint _rewards)external onlyGovernance{
        winnerXMPTRewards = _rewards;
    }

    function setUpLevelFee(uint _fee) external onlyGovernance{
        levelUpFee = _fee;
    }

    function setUpQualityFee(uint _fee) external onlyGovernance {
        qualityUpFee = _fee;
    }

}