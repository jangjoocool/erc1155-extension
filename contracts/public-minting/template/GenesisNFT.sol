// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./lib/Whitelist.sol";
import "./lib/Minting.sol";

contract GenesisNFT is ERC721URIStorage, Ownable, Whitelist, Minting {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenTracker;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function withdraw() external onlyOwner {
        _withdraw();
    }

    function resetWhitelist() public onlyOwner {
        _resetWhitelist();
    }

    function addWihtelist(address addr) external onlyOwner {
        _addWhitelist(addr);
    }

    function removeWhitelist(address addr) external onlyOwner {
        _removeWhitelist(addr);
    }

    function setupMinting(
        uint256 antibotInterval,
        uint256 mintLimitPerOnce,
        uint256 mintLimitPerAccount,
        uint256 mintStartBlockNumber,
        uint256 mintEndBlockNumber,
        uint256 mintStartIndex,
        uint256 maxMintingAmount,
        uint256 mintPrice,
        string calldata baseURIforMinting
    ) external onlyOwner {    
        _setupMinting(
            antibotInterval,
            mintLimitPerOnce,
            mintLimitPerAccount,
            mintStartBlockNumber,
            mintEndBlockNumber,
            mintStartIndex,
            maxMintingAmount,
            mintPrice,
            baseURIforMinting
        );
    }

    function mintingForSale(uint256 requestedCount) external payable mintingValidator(requestedCount, balanceOf(_msgSender())) {
        for(uint256 i = 0; i < requestedCount; i++) {
            uint256 tokenId = currentMintingIndex();
            _mint(_msgSender(), tokenId);
            _setTokenURI(tokenId, string(abi.encodePacked(mintingInfo().baseURIforMinting, Strings.toString(tokenId), ".json")));
            _addMintingIndex();
        }
        _setLastCallBlockNumber();
    }
}