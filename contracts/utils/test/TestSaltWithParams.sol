// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//TESTING ONLY
contract TestSaltWithParams {
    uint256 public _index;

    constructor(uint256 index_) {
        _index = index_;
    }
}