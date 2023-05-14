import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ERC20Recoverable } from "../../typechain-types";

describe("ERC20Recoverable", () => {
    let owner: SignerWithAddress;
    let alice: SignerWithAddress;
    let contract: ERC20Recoverable;

    beforeEach(async () => {
        const signers = await ethers.getSigners();
        owner = signers[0];
        alice = signers[1];

        const ERC20RecoverableFactory = await ethers.getContractFactory("ERC20Recoverable", owner);
        contract = await ERC20RecoverableFactory.deploy();
        await contract.deployed();
    });

    it("should allow setting password", async () => {
        const passwordHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"));
        await contract.connect(alice).setPassword(passwordHash);

        // Add a way to access private state for testing or use events
        // expect(await contract.getPassword(alice.address)).to.equal(passwordHash);
    });

    it("should allow recovering ERC20 tokens with correct password", async () => {
        const password = "password";
        const passwordHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(password));
        await contract.connect(alice).setPassword(passwordHash);

        // Mint some tokens to Alice
        await contract.connect(owner).mint(alice.getAddress(), 1000);

        // Alice sends all her tokens to the contract
        await contract.connect(alice).transfer(contract.address, 1000);

        // Recover the tokens
        await contract.connect(alice).erc20Recover(alice.getAddress(), password);

        // Check Alice's balance
        expect(await contract.balanceOf(alice.getAddress())).to.equal(1000);
    });

    it("should not allow recovering ERC20 tokens with incorrect password", async () => {
        const password = "password";
        const passwordHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(password));
        await contract.connect(alice).setPassword(passwordHash);

        // Mint some tokens to Alice
        await contract.connect(owner).mint(alice.getAddress(), 1000);

        // Alice sends all her tokens to the contract
        await contract.connect(alice).transfer(contract.address, 1000);

        // Try to recover with incorrect password
        await expect(contract.connect(alice).erc20Recover(alice.getAddress(), "wrongpassword"))
            .to.be.revertedWith("InvalidAttempt");
    });
});
