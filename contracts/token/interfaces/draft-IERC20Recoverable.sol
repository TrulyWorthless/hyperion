// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Recoverable {
    error InvalidType();
    error NonContract(address eoa);
    error InvalidAttempt(string message);

    enum Creation {
        CreateOne,
        CreateTwo
    }

    struct Derivative {
        Creation creation;
        address deployer;
        uint256 nonce;
        bytes32 salt;
        bytes bytecode;
    }
}
