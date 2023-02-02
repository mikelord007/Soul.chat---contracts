// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./SOULNFT.sol";

interface IPUSHCommInterface {
    function sendNotification(
        address _channel,
        address _recipient,
        bytes calldata _identity
    ) external;
}

contract SOULTOKEN is ERC20 {
    mapping(address => uint) public strikes;
    mapping(address => uint) public rewardCount;
    mapping(address => mapping(uint => uint8)) rewardTime;
    uint64 private referenceTime = 1673202600;
    uint24 private secondsInADay = 86400;
    address EPNS__COMM = 0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa;
    address CHANNEL_ADDRESS;
    SOULNFTS soulnft;

    constructor(
        string memory _name,
        string memory _symbol,
        address soulNFTContract,
        address channelAddress
    ) ERC20(_name, _symbol) {
        _mint(address(this), (100000 * 10) ^ 18);
        soulnft = SOULNFTS(soulNFTContract);
        CHANNEL_ADDRESS = channelAddress;
    }

    function assignStrike(address recipient) public {
        strikes[recipient]++;
    }

    function rewardNFT(address recipient) public {
        require(
            rewardCount[recipient] >= 100,
            "recipient not eligible for reward"
        );
        soulnft.RewardASoul(recipient);
    }

    function checkEligibilityForNFT(
        address recipient
    ) public view returns (bool) {
        return (rewardCount[recipient] == 100) ? true : false;
    }

    function isNotBanned(address recipient) public view returns (bool) {
        return strikes[recipient] < 5;
    }

    modifier isEligibleToReward() {
        require(isNotBanned(msg.sender), "Rewarder has too many strikes");
        _;
    }

    function rewardSoul(address recipient) public isEligibleToReward {
        require(isNotBanned(recipient), "Rewardee has too many strikes");
        require(recipient != msg.sender, "You can't reward yourself bruh");

        uint currentTime = block.timestamp;
        uint timepassed = currentTime - referenceTime;
        uint daysPassed = timepassed / secondsInADay;
        uint currentDay = referenceTime + daysPassed * secondsInADay;

        require(
            rewardTime[msg.sender][currentDay] < 3,
            "Rewarder Exceeding rewarding limit today."
        );

        rewardCount[recipient]++;
        rewardTime[msg.sender][currentDay]++;

        if (checkEligibilityForNFT(recipient)) {
            rewardNFT(recipient);
        }

        _transfer(address(this), recipient, (1 * 10) ^ 18);

        IPUSHCommInterface(EPNS__COMM)
            .sendNotification(
                CHANNEL_ADDRESS, // from channel - recommended to set channel via dApp and put it's value -> then once contract is deployed, go back and add the contract address as delegate for your channel
                recipient, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
                bytes(
                    string(
                        // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        abi.encodePacked(
                            "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                            "+", // segregator
                            "3", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                            "+", // segregator
                            "New Reward!", // this is notificaiton title
                            "+", // segregator
                            "You were rewarded a SOUL Token" // notification body
                        )
                    )
                )
            );
        IPUSHCommInterface(EPNS__COMM)
            .sendNotification(
                CHANNEL_ADDRESS, // from channel - recommended to set channel via dApp and put it's value -> then once contract is deployed, go back and add the contract address as delegate for your channel
                msg.sender, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
                bytes(
                    string(
                        // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        abi.encodePacked(
                            "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                            "+", // segregator
                            "3", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                            "+", // segregator
                            "Reward Sent", // this is notificaiton title
                            "+", // segregator
                            "Your reward was sent to the recipient" // notification body
                        )
                    )
                )
            );
    }
}
