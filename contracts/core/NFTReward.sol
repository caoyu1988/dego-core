pragma solidity ^0.5.0;

import '../library/Governance.sol';
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/math/Math.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/SafeERC20.sol";
import "../library/NFTOwnership.sol";

contract NFTReward is Governance,NFTOwnership {
    using SafeMath for uint256;

    uint256 public DURATION = 30 days;
    uint256 public initReward = 52500 * 1e18;
    uint256 public startTime = now + 365 days;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    uint256 public totalPower;

    mapping (address => uint256) public userRewardPerTokenPaid;
    mapping (address => uint256) public rewards;
    mapping (address => uint256) public weightBalances;
    mapping (address => uint256) public lastStakedTime;

    mapping(address => uint256) public powerBalances;
    mapping(uint256 => uint256) public stakeBalances;

    mapping (address => uint256 []) public playerNft;
    mapping (uint256 => uint256) public nftMapIndex;

    bool public hasStart = false;
    uint256 public fixRateBase = 100000;

    IERC20 public XMPT = IERC20(0x20118F8e38494EF7aEAd4B1095Fb0f1F309A4A70);

    event RewardAdded(uint256 _reward);
    event StakedNFT(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward (address _account){
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if(_account != address(0)){
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    //todo _dego.mint(address(this),_initReward)
    modifier checkHalve () {
        if(block.timestamp >= periodFinish){
            initReward = initReward.mul(50).div(100);
            rewardRate = initReward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(initReward);
        }
        _;
    }

    modifier checkStart(){
        require(block.timestamp > startTime ,'NOT START');
        _;
    }

    function stake(uint256 _nftId) public updateReward(msg.sender) checkHalve checkStart{
        uint256 [] storage nftIds = playerNft[msg.sender];
        if(nftIds.length == 0){
            nftIds.push(0);
            nftMapIndex[0] = 0;
        }
        nftIds.push(_nftId);
        nftMapIndex[_nftId] = nftIds.length -1;

        uint256 power = getStakeInfo(_nftId);

        uint256 stakedPower = powerBalances[msg.sender];
        uint256 stakingPower = power;

        if(stakingPower > 0){
            powerBalances[msg.sender] =stakedPower.add(stakingPower);
            stakeBalances[_nftId] = stakingPower;
            totalPower = totalPower.add(stakingPower);
        }

        _transfer(msg.sender,address(this),_nftId);
        lastStakedTime[msg.sender] = now;
        emit StakedNFT(msg.sender, _nftId);

    }

    function getReward() public updateReward(msg.sender) checkHalve checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            XMPT.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function getStakeInfo(uint256 _nftId)public view returns (uint256 power){
        power = NFTs[_nftId].power;
    }

    function rewardPerToken() public view returns (uint256){
        if(totalSupply() == 0){
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(totalSupply())
        );
    }

    function startNFTReward(uint256 _startTime)
    external
    onlyGovernance
    updateReward(address(0))
    {
        require(hasStart == false, "has started");
        hasStart = true;

        startTime = _startTime;

        rewardRate = initReward.div(DURATION);
        //XMPT.transfer(address(this), initReward);

        lastUpdateTime = startTime;
        periodFinish = startTime.add(DURATION);

        emit RewardAdded(initReward);
    }

    function totalSupply() public view returns (uint256){
        return  totalPower;
    }

    function balanceOf (address _account) public view returns (uint256){
        return powerBalances[_account];
    }

    function lastTimeRewardApplicable() public view returns (uint256){
        return Math.min(block.timestamp,periodFinish);
    }

    function earned (address _account) public view returns (uint256) {
        return balanceOf(_account).mul(rewardPerToken()).sub(userRewardPerTokenPaid[_account])
        .div(1e18).add(rewards[_account]);
    }
}