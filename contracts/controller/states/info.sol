// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../MLXData.sol";
import "../../interfaces/IBEP20.sol";

// MLX Controller: Info Variables
contract MLXInfo is MLXData {
    
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) internal _poolExists;
    mapping(address => uint256) public _referrersFarm;
    mapping(address => uint256) public _referrersStake;

    function _addPool(
        IBEP20 lpToken,
        uint256 allocPoint,
        uint256 lastRewardBlock,
        uint256 accMLXPerShare
    ) internal {
        poolInfo.push(PoolInfo({
            lpToken: lpToken,
            allocPoint: allocPoint,
            lastRewardBlock: lastRewardBlock,
            accMLXPerShare: accMLXPerShare
        }));
    }

    function _getPool(
        uint _pid
    ) internal view returns (PoolInfo memory) {
        return poolInfo[_pid];
    }
}
