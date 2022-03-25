//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

// Libraries / Interfaces
import "../interfaces/IBEP20.sol";
import "../utils/SafeBEP20.sol";
import "../utils/SafeMath.sol";
import "../helpers/Ownable.sol";
import "../utils/Utils360.sol";

// MLX Helpers
import "./MLXEvents.sol";
import "./MLXData.sol";
import "../tokens/bsc/imlx.sol";
import "../tokens/bsc/mlxpos.sol";

// MLX State Contracts
import "./states/govern.sol";
import "./states/limits.sol";
import "./states/info.sol";

contract MLXController is
    Ownable,
    MLXData,
    MLXEvents,
    MLXGovern,
    MLXLimits,
    MLXInfo
{
    using SafeBEP20 for IBEP20;
    using SafeMath for uint;

    IMetaple internal mlx;
    MLXPOS internal mlxpos;

    // MLX Controller: Data Variables
    uint256 public mlxPerBlock = 0.1 ether;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public referralReward = 5;
    uint256 internal _depositedMLX = 0;

    // MLX Controller: Double Staking Protocol
    uint internal stakingAt = 0;
    uint internal xPool = 1;
    uint internal xRewards = 2;
    uint public xLocked = 14 days;

    // MLX Controller: Modifiers
    modifier onlyPoolAdder() {
        require(_poolAdder == _msgSender(), appendADDR("MLXError:", _msgSender()," is not the pool owner"));
        _;
    }
    
    modifier validatePoolByPid(uint256 _pid) {
        require (_pid < poolInfo . length , "Pool does not exist") ;
        _;
    }

    constructor (
        address _mlx,
        address _mlxpos,
        uint _startBlock
    ) {
        mlx = IMetaple(_mlx);
        mlxpos = MLXPOS(_mlxpos);
        _poolAdder = _msgSender();

        startBlock = _startBlock;

        // staking pool
        _addPool(IBEP20(_mlx), 1000, startBlock, 0);
        // pos pool
        _addPool(IBEP20(_mlxpos), 2000, startBlock, 0);
        totalAllocPoint = 3000;

        _poolExists[address(_mlx)] = true;
        _poolExists[address(_mlxpos)] = true;

    }

    // Setter Functions
    function setXRewards(uint _rewards) external onlyPoolAdder {
        require(_rewards <= 5 && _rewards > 0, "MLXController: not valid");
        emit SetNewXRewards(xRewards, _rewards);
        xRewards = _rewards;
    }

    function setXPool(uint _xpool) external onlyPoolAdder {
        xPool = _xpool;
    }

    function setStakePool(uint stakePool) external onlyPoolAdder {
        stakingAt = stakePool;
    }
    
    // Getter Functions

    function getmlx() external view returns (IMetaple) {
        return mlx;
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from).mul(1);
    }

    function _getMLXPerBlock() internal view returns (uint256) {
        return mlxPerBlock;
    }

    function getMLXPerBlock() external view returns (uint256) {
        return _getMLXPerBlock();
    }

    function getRewards(address _referrer) external view returns (uint256, uint256) {
        uint256 _farmRewards = _referrersFarm[_referrer];
        uint256 _stakeRewards = _referrersStake[_referrer];

        return (_farmRewards, _stakeRewards);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function checkReferral(uint256 _amount) internal view returns(uint256){
        return _amount.sub(_amount.mul(referralReward).div(1e2));
    }

    // MLX Controller: Logic Functions
    // Add New Pools - Only Operated by Pool Adder
    function add( uint256 _allocPoint, IBEP20 _lpToken, bool _withUpdate ) external onlyPoolAdder {
        require(!_poolExists[address(_lpToken)], "[!] Pool Already Exists");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accMLXPerShare: 0
            })
        );
        _poolExists[address(_lpToken)] = true;
    }

    // Update the given pool's MLX allocation point. Can only be called by the owner.
    function set( uint256 _pid, uint256 _allocPoint, bool _withUpdate) external onlyPoolAdder validatePoolByPid(_pid) {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        if(_pid == stakingAt) {
            poolInfo[xPool].allocPoint = _allocPoint.mul(xRewards);
        }
    }

    // Update Functions
    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public validatePoolByPid(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (_pid == 0){
            lpSupply = _depositedMLX;
        }
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 mlxReward = multiplier.mul(_getMLXPerBlock()).mul(pool.allocPoint).div(totalAllocPoint);
    
        mlx.mintMLX(address(mlxpos), mlxReward);

        if (_devFee > 0) {
            uint256 devFee = mlxReward.mul(_devFee).div(1e4);
            mlx.mintMLX(_devAddress, devFee);
        }
        
        pool.accMLXPerShare = pool.accMLXPerShare.add(mlxReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

     // View function to see pending MLXs on frontend.
    function pendingMLX(uint256 _pid, address _user) external validatePoolByPid(_pid) view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accMLXPerShare = pool.accMLXPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        
        if (_pid == 0){
            lpSupply = _depositedMLX;
        }

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 mlxReward = multiplier.mul(_getMLXPerBlock()).mul(pool.allocPoint).div(totalAllocPoint);
            accMLXPerShare = accMLXPerShare.add(mlxReward.mul(1e12).div(lpSupply));
        }

        return checkReferral(user.amount.mul(accMLXPerShare).div(1e12).sub(user.rewardDebt));
    }

    // Initialize Pending Rewards with Referral Rewards
    function initPending(address sender, uint256 pending, string memory which) internal returns (uint256) {
        address referral = mlx.referrer(sender);
        uint256 refRewards = pending.mul(referralReward).div(100);
        uint256 pendingRewards = pending.sub(refRewards);

        safeMLXTransfer(sender, pendingRewards);
        if(referral != address(0)){
            safeMLXTransfer(referral, refRewards);
            if(compareStrings("farm", which)){
                _referrersFarm[referral] = _referrersFarm[referral].add(refRewards);
            }else {
                _referrersStake[referral] = _referrersStake[referral].add(refRewards);
            }
        }else{
            safeMLXTransfer(_defaultReferral, refRewards);
            if(compareStrings("farm", which)){
                _referrersFarm[_defaultReferral] = _referrersFarm[_defaultReferral].add(refRewards);
            }else {
                _referrersStake[_defaultReferral] = _referrersStake[_defaultReferral].add(refRewards);
            }
        }

        return pendingRewards;
    }

    // Deposit LP tokens to MLX Controller for MLX allocation.
    function deposit(uint256 _pid, uint256 _amount) external validatePoolByPid(_pid) {
        require(startBlock <= block.number, "[+] Farming not started");
        require (_pid != 0, "deposit MLX by stakinge");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accMLXPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0){
                initPending(msg.sender, pending, "farm");
            }
        }

        if (_amount > 0){
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            user._lastInvested = block.timestamp;
            user._blockInvested = block.number;
        }

        user.rewardDebt = user.amount.mul(pool.accMLXPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MLX Controller.
    function withdraw(uint256 _pid, uint256 _amount) external validatePoolByPid(_pid) {
        require (_pid != 0, "withdraw MLX by unstaking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "MLXC: amount > staked");
        updatePool(_pid);

        if (_pid == xPool) {
            require (
                block.timestamp.sub(user._lastInvested) > xLocked, "[+] X Pool Locked"
            );
        }

        uint256 pending = user.amount.mul(pool.accMLXPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0){
            initPending(msg.sender, pending, "farm");
        }

        if(_amount > 0){
            user.amount = user.amount.sub(_amount);
            uint _withdrawFee = _withdrawalFee(_amount, user._lastInvested);
            if(_withdrawFee > 0){
                pool.lpToken.safeTransfer(_devAddress, _withdrawFee);
                _amount = _amount.sub(_withdrawFee);
            }
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        user.rewardDebt = user.amount.mul(pool.accMLXPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake MLX tokens to MLX Controller
    function enterStaking(uint256 _amount) external {
        require(startBlock <= block.number, "[+] Staking not started");
        
        PoolInfo storage pool = poolInfo[stakingAt];
        UserInfo storage user = userInfo[stakingAt][msg.sender];
        updatePool(stakingAt);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accMLXPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                initPending(msg.sender, pending, "Stake");
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            user._lastInvested = block.timestamp;
            user._blockInvested = block.number;
            _depositedMLX = _depositedMLX.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accMLXPerShare).div(1e12);
        mlxpos.mint(msg.sender, _amount);
        emit Deposit(msg.sender, stakingAt, _amount);
    }

    // Withdraw MLX tokens from Staking.
    function leaveStaking(uint256 _amount) external {
        PoolInfo storage pool = poolInfo[stakingAt];
        UserInfo storage user = userInfo[stakingAt][msg.sender];
        require(user.amount >= _amount, "MLXC: amount > staked");
        updatePool(stakingAt);

        uint256 pending = user.amount.mul(pool.accMLXPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            initPending(msg.sender, pending, "Stake");
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            mlxpos.burn(msg.sender, _amount);

            uint _withdrawFee = _withdrawalFee(_amount, user._lastInvested);
            if(_withdrawFee > 0){
                pool.lpToken.safeTransfer(_devAddress, _withdrawFee);
                _amount = _amount.sub(_withdrawFee);
            }
            
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            _depositedMLX = _depositedMLX.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accMLXPerShare).div(1e12);
        emit Withdraw(msg.sender, stakingAt, _amount);
    }

    // Withdraw without rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external validatePoolByPid(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if(_pid == 0) {
            mlxpos.burn(msg.sender, user.amount);
        }

        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Transfer generated rewards
    function safeMLXTransfer(address _to, uint256 _amount) internal {
        mlxpos.safeMLXTransfer(_to, _amount);
    }

    // MLX Controller: Governing Functions
    function transferMLXOwner(address owner) external onlyOwner {
        mlx.transferOwnership(owner);
    }
    
    function transferPOSOwner(address owner) external onlyOwner {
        mlxpos.transferOwnership(owner);
    }

}