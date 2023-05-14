// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ISaltDeployer interface
 * @author Amir Shirif, Telcoin, LLC.
 * @notice Allows for creating contracts with deterministic addresses and predicting those contract creation addresses
 * @dev This interface provides methods for deploying contracts with the CREATE2 opcode
 * and for calculating the address of a contract to be deployed with CREATE2.
 */
interface ISaltDeployer {
    /**
     * @notice Deploys a contract using the CREATE2 opcode.
     * @dev The address of the deployed contract can be known in advance using {computeAddress}.
     * Requirements:
     * - `bytecode` must not be empty.
     * - `salt` must be unique for each contract deployment.
     * - The contract that calls this function must have an ETH balance of at least `amount`.
     * @param amount The amount of ETH to send to the newly deployed contract. Set to 0 if the contract is not `payable`.
     * @param salt A value used to create a unique contract address.
     * @param bytecode The bytecode of the contract to be deployed.
     * @return The address of the newly deployed contract.
     */
    function deployContract(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) external returns (address);

    /**
     * @notice Computes the address where a contract will be stored if deployed via {deployContract}.
     * @dev Any change in the `bytecodeHash` or `salt` will result in a new destination address.
     * @param salt The unique value used for the contract deployment.
     * @param bytecode The bytecode of the contract bytecode (including any constructor arguments) that is to be deployed.
     * @return The address where the contract will be deployed.
     */
    function computeAddress(
        bytes32 salt,
        bytes memory bytecode
    ) external view returns (address);
}