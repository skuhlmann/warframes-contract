// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../utils/base64.sol";

contract WarGamesOne is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    bool public mintOpen = true;
    uint256 public mintPrice = 100000000000000;
    string private _contractURI =
        "ipfs://QmNdwUhk3gFRCu2AVzrWshT9NXtSgDmwM1wAPSF4PspzHM"; /* URI for the contract metadata */
    string private _imageURI =
        "ipfs://QmQA5MGW5d2GwYNWEfSstjXsvVGxom2dUFPmqPoZ5bko87"; /* baseURI_ String to prepend to boxed token IDs */
    address public beneficiary = 0x8415Bd4Bc73CE815bf59D8973949d32accd45B26;

    /**
     * @dev Initializes contract
     */
    constructor() ERC721("WarGamesOne", "WAR") {}

    /**
     * @dev Mints 1 nft to msg.sender
     * Requirements:
     *
     * - `value` must match mint price
     * - `,mint must be open
     *
     */
    function mint() public payable {
        require(mintPrice == msg.value, "Incorrect payment amount");
        require(mintOpen, "Mint Closed");

        uint256 tokenId = _tokenIdCounter.current();

        (bool sent, ) = beneficiary.call{ value: msg.value }("");
        require(sent, "ETH not sent");

        _safeMint(msg.sender, tokenId + 1);
        _tokenIdCounter.increment();
    }

    /**
     * @dev Closes new minting
     *
     * Requirements:
     * - `owner` must be function caller
     */
    function setMintEnd() public onlyOwner {
        mintOpen = false;
    }

    /**
     * @dev Sets the contractURI
     * @param _newContractURI Metadata URI used for overriding contract URI
     *
     *
     * Requirements:
     *
     * - `owner` must be function caller
     */
    function setContractURI(string memory _newContractURI) public onlyOwner {
        _contractURI = _newContractURI;
    }

    /**
     * @dev Returns the tokenURI for a given tokenID
     * @param _tokenId tokenId
     * Requirements:
     *
     * - `tokenId` must exist
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory description = "SHALL WE PLAY A GAME";

        string memory metadata = string(
            abi.encodePacked(
                '{"name": "WARFRAMES #',
                Strings.toString(_tokenId),
                '", "description": "',
                description,
                '", "image": "',
                _imageURI,
                '", "external_url": "https://warframes.xyz", "attributes":[{"trait_type": "Name", "value":"Joshua"}]}'
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(metadata))));
    }
    /**
     * @dev Returns the contract uri metadata
     */
    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    /**
     * @dev Returns the current tokenID
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }
}
