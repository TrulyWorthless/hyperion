// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleMailbox {
    mapping(address => bytes) private _registry;

    function registerPublicKey(bytes memory publicKey) external {
        _registry[msg.sender] = publicKey;

    }

    function getPublicKey(address account) external view returns (bytes memory) {
        return _registry[account];
    }
}