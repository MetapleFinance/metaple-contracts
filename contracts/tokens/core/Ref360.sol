// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

/**
    Ref360 - Manage referrals and referree details
*/
contract Ref360 {
    mapping (address => address) private _referrals;
    mapping (address => address[]) public _allReferrals;

    function referrer(address owner) external view returns (address) {
        return _referrals[owner];
    }
    
    function getReferrals(address owner) external view returns (uint) {
        return _allReferrals[owner].length;
    }
    
    function _setReferrer(address owner, address refer) internal {
        require(_referrals[owner] == address(0) && owner != refer && refer != address(0), "[!] Invalid Referrer");
        _allReferrals[refer].push(owner);
        _referrals[owner] = refer;
    }
}