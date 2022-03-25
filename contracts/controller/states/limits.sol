// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../helpers/Ownable.sol";
import "../../utils/SafeMath.sol";
import "../../utils/Utils360.sol";
import "../MLXEvents.sol";

// MLX Controller: Withdraw Limits
contract MLXLimits is Ownable, MLXEvents, Utils360 {
    using SafeMath for uint;

    uint internal _lockedPeriod = 7 days;
    uint internal _withdrawFee = 3;
    uint internal _withdrawFeeMax = 1e3;

    function lockedPeriod() external view returns (uint) {
        return _lockedPeriod;
    }

    function withdrawFee() external view returns (uint) {
        return _withdrawFee;
    }

    function withdrawFeeMax() external view returns (uint) {
        return _withdrawFeeMax;
    }

    function setLockPeriod(uint lockP) external onlyOwner {
        _lockedPeriod = lockP;
    }

    function setWithdrawFee(uint fee) external onlyOwner {
        emit SetDevFee(_withdrawFee, fee);
        _withdrawFee = fee;
    }

    function canWithdrawRewards(uint investedAt) internal view {
        require(
            investedAt.add(_lockedPeriod) <= block.timestamp,
            appendINT("+ Withdrwal at ", investedAt.add(_lockedPeriod), " Epoch")
        );
    }

    function _withdrawalFee(uint amount, uint depositedAt) internal view returns (uint) {
        if (depositedAt.add(_lockedPeriod) > block.timestamp) {
            return amount.mul(_withdrawFee).div(_withdrawFeeMax);
        }

        return 0;
    }

    function withdrawalFee(uint amount, uint depositedAt) external view returns (uint) {
        return _withdrawalFee(amount, depositedAt);
    }
}
