// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Contract that will be used as a foundation of our ERC721 Smart contract
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// To handle and to store our tokenIDs
import "@openzeppelin/contracts/utils/Counters.sol";
// To implement the "toString()" function, that converts data into strings
import "@openzeppelin/contracts/utils/Strings.sol";
// To handle base64 data
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    // Associate all the methods inside the "Strings" library to the uint256 type
    using Strings for uint256;
    // Associate all the methods inside the "Counters" library to Counter
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Define the stats for the character
    struct Stats {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    // The mapping will link the NFT-Id to the stats of the NFT character.
    mapping(uint256 => Stats) public tokenIdToStats;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    // Define the generateCharacter function to generate the SVG image of our dynamic NFT
    // representing a character in a game.
    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // The bytes type(dynamic array) can stores strings and integers.
        // We  use it to store the SVG code representing the image of our NFT,
        // transformed into an array of bytes thanks to the abi.encodePacked() function.
        // The SVG code takes the return value of functions defined below and
        // use it to populate the stats properties.
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Level: ",
            getLevel(tokenId),
            "</text>",
            '<text x="50%" y="55%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            getSpeed(tokenId),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strenght: ",
            getStrength(tokenId),
            "</text>",
            '<text x="50%" y="65%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            getLife(tokenId),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    // Create the getLevel Function to retrieve the NFT Level
    function getLevel(uint256 tokenId) public view returns (string memory) {
        uint256 level = tokenIdToStats[tokenId].level;
        return level.toString();
    }

    // Create the getSpeed Function to retrieve the NFT Speed
    function getSpeed(uint256 tokenId) public view returns (string memory) {
        uint256 speed = tokenIdToStats[tokenId].speed;
        return speed.toString();
    }

    // Create the getStrength Function to retrieve the NFT Strenght
    function getStrength(uint256 tokenId) public view returns (string memory) {
        uint256 strength = tokenIdToStats[tokenId].strength;
        return strength.toString();
    }

    // Create the getLife Function to retrieve the NFT Life
    function getLife(uint256 tokenId) public view returns (string memory) {
        uint256 life = tokenIdToStats[tokenId].life;
        return life.toString();
    }

    // Create the getTokenURI Function to generate the tokenURI
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    // Create the Mint Function to create the NFT with on-chain metadata with 3 goals:
    // create a new NFT - inizialize the stats values - set the token URI.
    function mint() public {
        // increment the value of our _tokenIds
        _tokenIds.increment();
        // store its current value on a new uint256 variable
        uint256 newItemId = _tokenIds.current();
        // generate the NFT
        _safeMint(msg.sender, newItemId);
        // create a new item and initialize its stats value
        tokenIdToStats[newItemId].level = 0;
        tokenIdToStats[newItemId].speed = 2;
        tokenIdToStats[newItemId].strength = 3;
        tokenIdToStats[newItemId].life = 5;
        // set the token URI passing the newItemId and the return value of getTokenURI()
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    // Create the Train Function to raise your NFT stats
    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this NFT to train it!"
        );
        uint256 currentLevel = tokenIdToStats[tokenId].level;
        tokenIdToStats[tokenId].level = currentLevel + 1;

        uint256 currentSpeed = tokenIdToStats[tokenId].speed;
        tokenIdToStats[tokenId].speed = currentSpeed + random(currentSpeed);

        uint256 currentStrength = tokenIdToStats[tokenId].strength;
        tokenIdToStats[tokenId].strength =
            currentStrength +
            random(currentStrength);

        uint256 currentLife = tokenIdToStats[tokenId].life;
        tokenIdToStats[tokenId].life = currentLife + random(currentLife);

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    // Create a random number for the stats training
    function random(uint256 number) public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % number;
    }
}
