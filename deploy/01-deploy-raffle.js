const { network, ethers } = require("hardhat");
const { networkConfig, developmentChains } = require("../helper-hardhat-config");

module.exports = async function({getNamedAccounts , deployments}){
    const {deploy ,log, get} = deployments;
    const {deployer} = await getNamedAccounts();
    const chainId = network.config.chainId;
    let vrfCoordinatorV2Address , subscriptionId;

    if (developmentChains.includes(network.name)){
        const vrfCoordinatorV2Mock = await get("VRFCoordinatorV2Mock");
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
        
        // Get contract instance to interact with it
        const vrfCoordinatorV2Contract = await ethers.getContractAt("VRFCoordinatorV2Mock", vrfCoordinatorV2Address);
        const transactionResponse = await vrfCoordinatorV2Contract.createSubscription();
        const transactionReceipt = await transactionResponse.wait(1);
        
        // For ethers v6, events are in logs and we need to parse them
        subscriptionId = 1; // Default subscription ID for mock
        
        //fund the subscription
        //usually, you'd need the link token on a real network
        await vrfCoordinatorV2Contract.fundSubscription(subscriptionId , ethers.parseEther("7"));
        
        log(`VRF Coordinator Address: ${vrfCoordinatorV2Address}`);
        log(`Subscription ID: ${subscriptionId}`);
    }else{
        vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"];
        subscriptionId = networkConfig[chainId]["subscriptionId"];
    }

    const entranceFee = networkConfig[chainId]["entranceFee"];
    const gasLane = networkConfig[chainId]["gasLane"];
    const callbackGasLimit = networkConfig[chainId]["callbackGasLimit"];
    const interval = networkConfig[chainId]["interval"];

    const rafflle = await deploy("Raffle",{
        from:deployer,
        args:[entranceFee, vrfCoordinatorV2Address, gasLane, subscriptionId, callbackGasLimit, interval],
        log:true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });
}

module.exports.tags = ["all", "raffle"];