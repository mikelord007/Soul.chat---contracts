// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract SOULNFTS is ERC721, Ownable {

    uint tokenCount;

    constructor(string memory _name, string memory _symbol) ERC721 (_name, _symbol) {
        _safeMint(msg.sender,tokenCount);
        tokenCount++;
    }
    
    function RewardASoul(address soul) onlyOwner external {
        _safeMint(soul,tokenCount);
        tokenCount++;
    }

}