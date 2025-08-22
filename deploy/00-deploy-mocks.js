const { developmentChains } = require("../helper-hardhat-config");
const { network, ethers } = require("hardhat");

//local smart contract therefore we need to mention base fee and gas price link
BASE_FEE = ethers.parseEther("0.25"); // 0.25 LINK per request
GAS_PRICE_LINK = 1e9; // 1000000000 LINK per gas

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  if (developmentChains.includes(network.name)) {
    log("Local network detected! Deploying mocks...");
    await deploy("VRFCoordinatorV2Mock", {
      from: deployer,
      args: [BASE_FEE, GAS_PRICE_LINK],
      log: true,
      waitConfirmations: network.config.blockConfirmations || 1,
    });
    log("Mocks deployed!");
    log(
      "You are deploying to a local network, you'll need a local network running to interact"
    );
    log(
      "Please run `yarn hardhat console` to interact with the deployed smart contracts!"
    );
  }
};
module.exports.tags = ["all", "mocks"];
