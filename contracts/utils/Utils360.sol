// SPDX-License-Identifier: MTI
pragma solidity 0.8.11;
import "./SafeMath.sol";

/**
    Utils360 - Quick Tools
*/
contract Utils360 {
    using SafeMath for uint;
    
    function append(string memory a, string memory b, string memory c) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c));
    }

    function appendADDR(string memory a, address b, string memory c) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c));
    }

    function appendINT(string memory a, uint b, string memory c) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c));
    }
}