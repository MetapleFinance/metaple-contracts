// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IMetaple {
    function initReferral(address _referrer) external;
    function referrer(address owner) external view returns (address);
    function mintMLX(address account, uint256 amount) external returns (bool);
    function transferOwnership(address _newOwner) external;
}