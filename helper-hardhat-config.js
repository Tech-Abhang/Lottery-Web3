// per network configuration
const { ethers } = require("hardhat");

//sepolia works on real vrf (smart contract) for randomness
//hardhat and localhost works on mock vrf (smart contract) for randomness

const networkConfig = {
    11155111: {
        name: "sepolia",
        vrfCoordinatorV2: "0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B",
        entranceFee: ethers.parseEther("0.01"), //0.01 ETH
        gasLane: "0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef", // 30 gwei Key Hash
        subscriptionId:"0",
        callbackGasLimit: "500000", // 500,000 gas
        interval: "30", // 30 seconds
    },
    31337:{
        name: "hardhat",
        entranceFee: ethers.parseEther("0.01"), //0.01 ETH
        gasLane: "0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef", 
        callbackGasLimit: "500000", // 500,000 gas
        interval: "30", // 30 seconds
    }
}    

const developmentChains = ["hardhat", "localhost"];

module.exports = {
    networkConfig,
    developmentChains,
};