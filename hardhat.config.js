require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");

SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL || "";
PRIVATE_KEY = process.env.PRIVATE_KEY || "";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
      blockConfirmations: 1,
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts:process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
      blockConfirmations: 6,
    },
  },
  solidity: "0.8.28",
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};
