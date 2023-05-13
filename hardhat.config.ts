import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-solhint";
import "@nomiclabs/hardhat-ethers";

import "@openzeppelin/hardhat-upgrades";
import "@typechain/ethers-v5";
import "@typechain/hardhat";
import "solidity-coverage";

dotenv.config();

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    ethereum: {
      url: "https://eth-mainnet.alchemyapi.io/v2/" + process.env.ETHEREUM_API_KEY
    },
    polygon: {
      url: "https://polygon-mainnet.g.alchemy.com/v2/" + process.env.POLYGON_API_KEY
    },
    avalanche: {
      url: "https://api.avax.network/ext/bc/C/rpc",
    },
    sepolia: {
      url: "https://eth-sepolia.alchemyapi.io/v2/" + process.env.SEPOLIA_API_KEY
    },
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/" + process.env.MUMBAI_API_KEY
    },
    fuji: {
      url: "https://api.avax-test.network/"
    },
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: {
        mnemonic: process.env.GANACHE_MNEMONIC,
        count: 10
      }
    },
    tenderly: {
      url: "https://mainnet.gateway.tenderly.co/" + process.env.TENDERLY_API_KEY
    }
  },
  solidity: {
    compilers: [
      {
        version: "0.8.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
  etherscan: {
    apiKey: {
      ethereum: process.env.ETHERSCAN_API_KEY || "",
      goerli: process.env.ETHERSCAN_API_KEY || "",
      polygon: process.env.POLYGONSCAN_API_KEY || "",
      mumbai: process.env.POLYGONSCAN_API_KEY || ""
    }
  }
};

export default config;
