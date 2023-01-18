// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import "./SOULNFT.sol";

contract SOULTOKEN is ERC20 {

    mapping (address=>uint) public strikes;
    mapping (address=>uint) public rewardCount;
    mapping (address=>mapping(uint=>uint8)) rewardTime;
    uint64 private referenceTime = 1673202600;
    uint24 private secondsInADay = 86400;
    SOULNFTS soulnft;

    constructor(string memory _name, string memory _symbol, address soulNFTContract) ERC20(_name, _symbol) {
        _mint(address(this), 100000 * 10^18);
        soulnft = SOULNFTS(soulNFTContract);
    }

    function assignStrike(address recipient) public {
        strikes[recipient]++;
    }

    function rewardNFT(address recipient) public {
        require(rewardCount[recipient] >= 100, "recipient not eligible for reward");
        soulnft.RewardASoul(recipient);
    }

    function checkEligibilityForNFT(address recipient) view public returns(bool)  {
        return rewardCount[recipient] >= 100;
    }

    modifier isEligibleToReward {
        require(strikes[msg.sender] < 5, "Rewarder has too many strikes");
        _;
    }

    function rewardSoul(address recipient) public isEligibleToReward {
        uint currentTime = block.timestamp;
        uint timepassed = currentTime - referenceTime;
        uint daysPassed = timepassed/secondsInADay;
        uint currentDay = referenceTime + daysPassed * secondsInADay;

        require(rewardTime[msg.sender][currentDay] < 3, "Rewarder Exceeding rewarding limit today.");
        
        transferFrom(address(this),recipient,1);
        rewardCount[recipient]++;
        rewardTime[msg.sender][currentDay]++;

        if(checkEligibilityForNFT(recipient)){
            rewardNFT(recipient);
        }
    }

}