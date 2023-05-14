import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { SaltDeployer, TestSaltNoParams, TestSaltWithParams } from "../../typechain-types";

describe("SaltDeployer", () => {
    let owner: SignerWithAddress;
    let saltDeployer: SaltDeployer;

    beforeEach(async () => {
        [owner] = await ethers.getSigners();

        const SaltDeployerFactory = await ethers.getContractFactory("SaltDeployer");
        saltDeployer = (await SaltDeployerFactory.deploy()) as SaltDeployer;
        await saltDeployer.deployed();
    });

    describe("SaltDeployer without params", () => {
        it("should deploy a contract and compute its address", async () => {
            const TestSaltNoParamsFactory = await ethers.getContractFactory("TestSaltNoParams");

            const salt = ethers.utils.randomBytes(32);
            const bytecode = TestSaltNoParamsFactory.bytecode;
            const expectedAddress = await saltDeployer.computeAddress(salt, bytecode);

            await saltDeployer.deployContract(0, salt, bytecode);

            // Check the contract was deployed
            expect(await ethers.provider.getCode(expectedAddress)).to.not.equal('0x');

            // Check the computed address matches the actual one
            expect(expectedAddress).to.equal(ethers.utils.getCreate2Address(saltDeployer.address, salt, ethers.utils.keccak256(bytecode)));
        });

        it("should fail when attempting to deploy a contract with the same salt", async () => {
            const TestSaltNoParamsFactory = await ethers.getContractFactory("TestSaltNoParams");

            const salt = ethers.utils.randomBytes(32);
            const bytecode = TestSaltNoParamsFactory.bytecode;

            await saltDeployer.deployContract(0, salt, bytecode);

            // Try to deploy again with the same salt and bytecode
            await expect(saltDeployer.deployContract(0, salt, bytecode)).to.be.revertedWith("Create2: Failed on deploy");
        });
    });

    describe("SaltDeployer with params", () => {
        it("should deploy a contract and compute its address", async () => {
            const index = 123;
            const TestSaltWithParamsFactory = await ethers.getContractFactory("TestSaltWithParams");

            const salt = ethers.utils.randomBytes(32);
            const bytecode = TestSaltWithParamsFactory.getDeployTransaction(index).data;
            const expectedAddress = await saltDeployer.computeAddress(salt, bytecode!);

            await saltDeployer.deployContract(0, salt, bytecode!);

            // Check the contract was deployed
            expect(await ethers.provider.getCode(expectedAddress)).to.not.equal('0x');

            // Check the computed address matches the actual one
            expect(expectedAddress).to.equal(ethers.utils.getCreate2Address(saltDeployer.address, salt, ethers.utils.keccak256(bytecode!)));

            // Check the deployed contract's state
            const testSaltWithParams = TestSaltWithParamsFactory.attach(expectedAddress);
            expect(await testSaltWithParams._index()).to.equal(index);
        });

        it("should fail when attempting to deploy a contract with the same salt", async () => {
            const index = 123;
            const TestSaltWithParamsFactory = await ethers.getContractFactory("TestSaltWithParams");

            const salt = ethers.utils.randomBytes(32);
            const bytecode = TestSaltWithParamsFactory.getDeployTransaction(index).data;

            await saltDeployer.deployContract(0, salt, bytecode!);

            // Try to deploy again with the same salt and bytecode
            await expect(saltDeployer.deployContract(0, salt, bytecode!)).to.be.revertedWith("Create2: Failed on deploy");
        });
    });
});