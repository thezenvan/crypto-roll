// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

contract Staker {
  mapping (address => uint) public balances;
  mapping (address => uint) public rolls;
  event Stake(address _from, uint256 _amount);
  event Rolled(address _from, uint _roll);
  uint public randomChars;
  address public playerWonAddress;
  uint public winningRoll;
  uint public playerRoll;
  uint randNonce = 0;

  constructor() {
      // generate random charachters
      randomChars = genRandom();
  }

  function getRoll() public {
    playerRoll = uint(blockhash(block.number-1)) % 10000;
    rolls[msg.sender] = playerRoll;
    emit Rolled(msg.sender, playerRoll);

    // ************** DEBUG ************
    //playerWonAddress = msg.sender;
    //playerRoll = randomChars;

    if (rolls[msg.sender] == randomChars) gotWinningRoll();
  }

  function gotWinningRoll() internal {
    // send contract funds
    payable(msg.sender).transfer(address(this).balance);
    playerWonAddress = msg.sender;
    winningRoll = randomChars;
  }

  function getRandomChars() public view returns(uint256) {
    return randomChars;
  }

  function genRandom() private returns (uint) {
    randNonce++; 
    return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 10000;
}

  // set balance for tracking and emits Stake event for front-end
  function stake() public payable {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
    getRoll();

    // clear address in case someone won. improve this
    if (playerWonAddress!=address(0) && playerWonAddress!=msg.sender) {
      playerWonAddress = address(0);
      randomChars = genRandom();
    }
  }

  // to support receiving ETH by default
  receive() external payable {
    stake();
  }
}