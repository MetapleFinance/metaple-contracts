// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../helpers/Ownable.sol";
import "../MLXEvents.sol";

// MLX Controller: Governing Addresses
contract MLXGovern is Ownable, MLXEvents {
    address internal _devAddress;
    address internal _poolAdder;
    address internal _defaultReferral;
    uint256 internal _devFee;

    function devAddress() external view returns (address) {
        return _devAddress;
    }

    function poolAdder() external view returns (address) {
        return _poolAdder;
    }

    function defaultReferral() external view returns (address) {
        return _defaultReferral;
    }

    function devFee() external view returns (uint256) {
        return _devFee;
    }

    function setDevAddress(address _dev) external onlyOwner {
        emit SetDevAddress(_devAddress, _dev);
        _devAddress = _dev;
    }

    function setPoolAdder(address poolAddr) external onlyOwner {
        emit SetPoolAdder(_poolAdder, poolAddr);
        _poolAdder = poolAddr;
    }

    function setReferralAddress(address _referralAddr) external onlyOwner {
        emit SetReferralAddress(_defaultReferral, _referralAddr);
        _defaultReferral = _referralAddr;
    }

    function setDevFee(uint256 value) external onlyOwner {
        emit SetDevFee(_devFee, value);
        _devFee = value;
    }
}