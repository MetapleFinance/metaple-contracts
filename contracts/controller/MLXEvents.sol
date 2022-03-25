//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract MLXEvents {
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    
    event SetDevAddress(address indexed oldDev, address indexed newDev);
    event SetPoolAdder(address indexed oldAdder, address indexed newAdder);
    event SetReferralAddress(address indexed oldAddr, address indexed newAddr);
    event SetMLXPerBlock(uint256 oldPerBlock, uint256 newPerBlock);
    event SetMultiplier(uint256 oldMultiplier, uint256 newMultiplier);
    event SetMinReward(uint256 oldReward, uint256 newReward);
    event SetReferralReward(uint256 oldReferralReward, uint256 newReferralReward);
    event SetDevFee(uint256 oldFee, uint256 newFee);
    event SetNewMLX(address indexed _newMLX);
    event SetNewMLXPos(address indexed _newMLXPos);
    event SetNewXRewards(uint _old, uint _new);
}