// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../interfaces/IBEP20.sol";

contract MLXData {
    struct PoolInfo {
        IBEP20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accMLXPerShare;
    }

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint _lastInvested;
        uint _blockInvested;
    }
}