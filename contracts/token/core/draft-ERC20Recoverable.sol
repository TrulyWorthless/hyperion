// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/SignatureCheckerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "@openzeppelin/contracts/utils/Create2.sol";

import "../interfaces/draft-IERC20Recoverable.sol";

contract ERC20Recoverable is
    ERC20PresetMinterPauserUpgradeable,
    ERC20PermitUpgradeable,
    ERC20CappedUpgradeable,
    IERC20Recoverable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    mapping(address => bytes32) private _passwords;

    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant SUPPORT_ROLE = keccak256("SUPPORT_ROLE");

    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 cap_
    ) external initializer {
        ERC20PresetMinterPauserUpgradeable.initialize(name_, symbol_);
        __ERC20Permit_init(name_);
        __ERC20Capped_init(cap_);
    }

    function setPassword(bytes32 passwordHash) external {
        _passwords[_msgSender()] = passwordHash;
    }

    /***************************************
     *
     * Pure Hash Patterns
     *
     ***************************************/

    function calculatePasswordHash(string memory password) public pure returns (bytes32) {
        return keccak256(bytes(password));
    }

    function computeAddress(
        bytes32 salt,
        bytes memory bytecode,
        address deployer
    ) external pure returns (address) {
        return Create2.computeAddress(salt, keccak256(bytecode), deployer);
    }

    function getMessage() public pure returns (string memory) {
        return "Placeholder";
    }

    function deriveAddress(Derivative memory derivative) public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(derivative.deployer, derivative.nonce)))));
    }
    
    function deriveAddress2(Derivative memory derivative) public pure returns (address) {
        return Create2.computeAddress(derivative.salt, keccak256(derivative.bytecode), derivative.deployer);
    }

    /***************************************
     *
     * Recovery Patterns
     *
     ***************************************/

    function erc20Recover(address account, string memory password) external {
        if (calculatePasswordHash(password) != _passwords[account]) {
            revert InvalidAttempt(password);
        }

        _transfer(account, _msgSender(), balanceOf(account));
        _passwords[account] = bytes32(0);
    }

    function erc20Retrieve(
        Derivative[] memory derivatives,
        bytes memory signature,
        address tokenPrison,
        address destination,
        uint256 amount
    ) external requireContract(tokenPrison) {
        address current = tokenPrison;
        for (uint i = 0; i < derivatives.length; i++) {
            if (derivatives[i].creation == Creation.CreateOne) {
                require(current == deriveAddress(derivatives[i]));
                current = derivatives[i].deployer;
            } else if (derivatives[i].creation == Creation.CreateTwo) {
                require(current == deriveAddress2(derivatives[i]));
                current = derivatives[i].deployer;
            } else {
                revert InvalidType();
            }
        }

        require(current == _msgSender() || SignatureCheckerUpgradeable.isValidSignatureNow(current, keccak256(bytes(getMessage())), signature));

        _transfer(tokenPrison, destination, amount);
    }

    function erc20Rescue(
        IERC20Upgradeable token,
        address destination,
        uint256 amount
    ) external onlyRole(SUPPORT_ROLE) {
        token.safeTransfer(destination, amount);
    }

    /***************************************
     *
     * Override
     *
     ***************************************/

    function _mint(
        address account,
        uint256 amount
    ) internal virtual override(ERC20CappedUpgradeable, ERC20Upgradeable) {
        require(totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        ERC20Upgradeable._mint(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address,
        uint256
    )
        internal
        virtual
        override(ERC20Upgradeable, ERC20PresetMinterPauserUpgradeable)
    {
        if (from == address(0)) _requireNotPaused();
    }

    /***************************************
     *
     * Modifiers
     *
     ***************************************/

    modifier requireContract(address possibleContract) {
        if (!AddressUpgradeable.isContract(possibleContract))
            revert NonContract(possibleContract);
        _;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
