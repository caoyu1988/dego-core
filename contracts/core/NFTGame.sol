pragma solidity ^0.5.0;
import "../library/NFTOwnership.sol";


contract NFTGame is NFTOwnership{

    uint8 num = 5;
    uint8 public count = 0;
    uint256 public nonce = 0;
    uint256 public playFee = 0.01 ether;
    uint256 winnerXMPTRewards = 500 * 1e18;

    address public teamWallet = 0x0f61A80aB19fe9aD0Dce03b6D4297521eC6Cf4f2;
    address[5] plays;

    mapping(uint => address) public nonceToWinner;
    mapping(address => uint) public winnerToCounter;


    using SafeMath for uint;

    function buyLottery() public payable returns(bool){
        require(msg.value >= playFee);
        require(count < num);
        require(joinRequire(msg.sender) == false);
        plays[count] = msg.sender;
        count++;
        if (count == num) {
            distributeRewards();
        }
        return true;
    }

    function joinRequire(address _cormorant) private view returns(bool) {
        bool contains = false;
        for(uint i = 0; i < num; i++) {
            if (plays[i] == _cormorant) {
                contains = true;
            }
        }
        return contains;
    }

    function distributeRewards() private returns(address) {
        require(count == num);
        address winner = plays[winnerNumber()];
        distributeLoser(winner);
        distributeWinner(winner);
        nonceToWinner[nonce] = winner;
        winnerToCounter[winner] = winnerToCounter[winner].add(1);
        delete plays;
        count = 0;
        return winner;
    }

    function distributeLoser(address _winner) private returns(bool){
        for(uint i = 0;i<num; i++){
            if(plays[i] != _winner){
                address(uint160(plays[i])).transfer(playFee.mul(11).div(10));
            }
        }
    }

    function distributeWinner(address _winner)private returns(bool){
        //address(uint160(_winner)).transfer(address(this).balance.div(2));
        address(uint160(teamWallet)).transfer(playFee.div(5));
        XMPT.transfer(_winner,winnerXMPTRewards);
        mint(_winner);
    }

    function getWinnerByOwner(address _owner) external view returns(uint [] memory){
        uint winnerTimes = winnerToCounter[_owner];
        uint [] memory result = new uint [](winnerTimes) ;
        uint counter = 0;
        for(uint i =0;i< nonce;i++){
            if(nonceToWinner[i] == _owner){
                result[counter] = nonce;
                counter ++;
            }
        }
    }


    function winnerNumber() private returns(uint) {
        uint256 winner = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))).mod(5);
        nonce++;
        return winner;
    }


    function ethJackpot() public view returns(uint){
        return address(this).balance;
    }

    function xmptJackpot() public view  returns (uint256){
        return  XMPT.balanceOf(address(this));
    }
}