// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";

// lottery contract
contract Lottery is VRFConsumerBaseV2  {


  VRFCoordinatorV2Interface COORDINATOR;

  // Your subscription ID.
  uint64 s_subscriptionId;

  // Rinkeby coordinator. For other networks,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

  // Depends on the number of requested values that you want sent to the
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
  // so 100,000 is a safe default for this example contract. Test and adjust
  // this limit based on the network that you select, the size of the request,
  // and the processing of the callback request in the fulfillRandomWords()
  // function.
  uint32 callbackGasLimit = 100000;

  // The default is 3, but you can set this higher.
  uint16 requestConfirmations = 3;

  // For this example, retrieve 2 random values in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numWords =  2;

  uint256[] public s_randomWords;
  uint256 public s_requestId;
  
  address s_owner;

    // manager address
    address public manager;
    // lottery players
    address[] public  players;
    // lottery players
    address[] public  winners;

    // target amount of tickets
    uint public target_amount;
    // price of ticket
    uint public ticket_price;
    // max price of ticket
    uint public max_ticket_price;
    // check if game finished
    bool public isGameEnded = true;
    bool public isReadyPickWinner = false;
    uint public startedTime = 0;


    // add mapping
    // mapping(address => bool) playerEntered;

    // add event
    event PickWinner(address indexed winner, uint balance);

    // constructor
    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        // define administrator with deployer
        manager = msg.sender;
        isGameEnded = true;

        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        // TODO fixed
        s_subscriptionId = uint64(8586);
    }

     // Assumes the subscription is funded sufficiently.
  // 31212937063425431805180616141006738352880952378283753989774217677407287236499
  // 114462454551599691336885503684708734676279007154771611302349054836583002276787
  function requestRandomWords() public returns (uint256){
    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
    return s_requestId;

  }
  
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;
  }


    // role middleware
    modifier restricted() {
        require(msg.sender == manager,"only manager has access");
        _;
    }
    // middleware to check if game is on or off
    modifier onGame() {
        require(!isGameEnded && !isReadyPickWinner, "Game has not started yet.");
        _;
    }

    // Get Balance of pool
    function balanceInPool()public view returns(uint){
        return address(this).balance;
    }

    // enter the game
    function enter() public payable onGame{
        // require(!playerEntered[msg.sender], "You have already taken the ticket");
        require(msg.value == ticket_price,"the price doesnot match with standard price");
        require(target_amount > 0, "the whole tickets has been sold");
        players.push(msg.sender);

        target_amount = target_amount - 1;
        if(target_amount == 0) {
            isReadyPickWinner = true;
        }
    }

    // initialize the game
    function initialize(
        uint _ticketPrice,
        uint _ticketAmount
    ) public restricted {
        // before init newly, previous game should be finished.
        require(isGameEnded, "Game is running now.");

        startedTime = block.timestamp;

        ticket_price = _ticketPrice;
        target_amount = _ticketAmount;
        isGameEnded = false;
        isReadyPickWinner = false;
    }

    function random() public returns (uint256) {
        return requestRandomWords();
        // return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players)));
    }

    function pickWinner() public restricted {
        require(isReadyPickWinner, "Game is running now.");

        uint index = random() % players.length;
        address payable winner = payable(players[index]);
        players = new address[](0);
        uint winBalance = address(this).balance;
        winner.transfer(address(this).balance);
        isGameEnded = true;
        winners.push(winner);

        emit PickWinner(winner, winBalance);
    }

    function getPlayers()public view returns(address[] memory){
        return players;
    }
    
    function getWinners()public view returns(address[] memory){
        return winners;
    }

    function getPlayerNumber() public view returns(uint) {
        return players.length;
    }

    function getStartedTime() public view returns(uint) {
        return block.timestamp - startedTime;
    }

    function getPercent() public view returns(uint) {
        if(isGameEnded) return 0;
        if(isReadyPickWinner) return 100;
        return getPlayerNumber() * 100 / (target_amount + getPlayerNumber());
    }
}