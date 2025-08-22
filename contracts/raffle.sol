// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract Raffle is VRFConsumerBaseV2 , AutomationCompatibleInterface {

  /* ======= Types ======= */
  enum RaffleState {
    OPEN,
    CALCULATING
  } // uint256 0, 1

  /* ======= State Variables ======= */
  uint256 private immutable entranceFee;
  address payable[] private s_players;
  VRFCoordinatorV2Interface private immutable COORDINATOR;

  uint64 private immutable i_subscriptionId;
  address s_owner;
  address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
  bytes32 private immutable i_keyHash ;
  uint32 private immutable i_callbackGasLimit ;
  uint16 private constant REQUEST_CONFIRMATION = 3;
  uint32 private constant NUM_WORDS =  1;

  /* ======= Lottery Variables ======= */
  address private s_recentWinner;
  RaffleState private s_raffleState; 
  uint256 private s_lastTimeStamp;
  uint256 private immutable i_interval;


  /* ======= Events ======= */
  event RaffleEnter(address indexed player);
  event RequestedRaffleWinner(uint256 indexed requestId);
  event WinnerSelected(address indexed winner);

  /* ======= Errors ======= */
  error Raffle__notEnoughEthSent();
  error Raffle__transferFailed();
  error Raffle__RaffleNotOpen();
  error Raffle__UpkeepNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 raffleState);

  /* ===== Modifiers / Constuctor ===== */
  constructor(uint256 _entranceFee, address _vrfCoordinator , bytes32 s_keyHash ,uint64 s_subscriptionId , uint32 callbackGasLimit , uint256 _interval)  VRFConsumerBaseV2(_vrfCoordinator)  {
    COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
    entranceFee = _entranceFee;
    i_subscriptionId = s_subscriptionId;
    i_callbackGasLimit = callbackGasLimit;
    i_keyHash = s_keyHash;
    s_raffleState = RaffleState.OPEN;
    s_lastTimeStamp = block.timestamp;
    i_interval = _interval;
  }
  
  /* ======= Functions ======= */
  // Use send money payable function
  function enterRaffle() public payable {
    if(msg.value < entranceFee) {
      revert Raffle__notEnoughEthSent();
    }
    if(s_raffleState != RaffleState.OPEN) {
      revert Raffle__RaffleNotOpen();
    }
    s_players.push(payable(msg.sender));
    // event with function name reversed
    emit RaffleEnter(msg.sender);
  }

  // Pick a ramdom winner
  function performUpkeep(bytes calldata /* performData */) external override {
    (bool upkeepNeeded, ) = this.checkUpkeep("");

    if(!upkeepNeeded) {
      revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
    }

    s_raffleState = RaffleState.CALCULATING;

    // Request the random number from Chainlink VRF
      uint256 requestId = COORDINATOR.requestRandomWords( i_keyHash, i_subscriptionId, REQUEST_CONFIRMATION, i_callbackGasLimit, NUM_WORDS );
      emit RequestedRaffleWinner(requestId); 
  }

  function fulfillRandomWords(uint256 /* requestId */, uint256[] memory randomWords) internal override {
    // This function will be called by Chainlink VRF with the random number
    // Use the random number to select a winner from s_players
    // Transfer the prize to the winner
    // Reset the players array for the next raffle

    uint256 winnerIndex = randomWords[0] % s_players.length;
    address payable winner = s_players[winnerIndex];
    s_recentWinner = winner; 
    s_raffleState = RaffleState.OPEN; // reset raffle state 
    s_players = new address payable[](0); // reset the players array
    s_lastTimeStamp = block.timestamp; // reset the last timestamp

    //send the prize to the winner
    (bool success, ) = winner.call{value: address(this).balance}("");
    if(!success) {
      revert Raffle__transferFailed();
    }
    emit WinnerSelected(winner);
  }

  // this is the function that the Chainlink Automation nodes call
  // they look for `upkeepNeeded` to return true
  // for that 1. time interval should have passed 
  // 2. lottery should have at least 1 player and some ETH
  // 3. subscription is funded with LINK
  // 4. lottery should be in "open" state

  function checkUpkeep(bytes calldata /* checkData */) public view override returns (bool upkeepNeeded, bytes memory /* performData */){
    bool isOpen = (RaffleState.OPEN == s_raffleState);
    bool timepassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
    bool hasPlayers = (s_players.length > 0);
    bool hasBalance = address(this).balance > 0;
    upkeepNeeded = (isOpen && timepassed && hasPlayers && hasBalance);
    return (upkeepNeeded, "0x0"); 
  }

  /* ======= View / Pure Functions ======= */
  function getEntranceFee() public view returns(int256){
    return int256(entranceFee);
  }

  function getPlayers() public view returns(address payable[] memory){
    return s_players;
  }

  function getRecentWinner() public view returns(address){
    return s_recentWinner;
  }

  function getRaffleState() public view returns(RaffleState){
    return s_raffleState;
  }

  function getNumWords() public pure returns(uint256){
    return NUM_WORDS;
  }

  function getNumberOfPlayers() public view returns(uint256){
    return s_players.length;
  }

  function getRequestConfirmations() public pure returns(uint256){
    return REQUEST_CONFIRMATION;
  }

}
