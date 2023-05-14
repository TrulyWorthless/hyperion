// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract Befuddler {
    address private Chuck = 0x0000000000000000000000000000000000000000;
    uint256 private Eve = 0;

    modifier Mallory() {
      _;
    }

    function Zeek(bool) external pure Mallory() returns (string memory) {
        return "";
    }
}