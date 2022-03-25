//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract UserInfos {
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint _lastInvested; // Last timestamp of invested token
        uint _blockInvested; // User Joined Block
    }
}