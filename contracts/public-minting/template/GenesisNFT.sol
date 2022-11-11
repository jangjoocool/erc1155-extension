// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./lib/Whitelist.sol";
import "./lib/MintingSales.sol";

contract GenesisNFT is ERC721URIStorage, Ownable, Whitelist, MintingSales {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenTracker;
    uint256 public whitelistLimitCount;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function withdraw() external onlyOwner {
        _withdraw();
    }

    function setWhitelistLimit(uint256 limitCount) external onlyOwner {
        whitelistLimitCount = limitCount;
    }

    function resetWhitelist() external onlyOwner {
        _removeWhitelistBatch(allWhitelist());
        whitelistLimitCount = 0;
    }

    function addWhitelist(address addr) external onlyOwner {
        require(allWhitelist().length < whitelistLimitCount, "Whitelist: limit reached");
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
    ) 
        external onlyOwner
    {    
        _setupSales(
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

    function publicMintingForSales(uint256 requestedCount) 
        external
        payable
        blockNumberValidator
        salesValidator(requestedCount, balanceOf(_msgSender()))
    {
        -mintingForSales(requestedCount);
        _setLastCallBlockNumber();
    }

    function privateMintingForSales(uint256 requestedCount)
        external
        payable
        onlyWhitelist
        salesValidator(requestedCount, balanceOf(_msgSender()))
    {
        -mintingForSales(requestedCount);
        _setLastCallBlockNumber();
    }

    function _mintingForSales(uint256 requestedCount) internal {
        for(uint256 i = 0; i < requestedCount; i++) {
            uint256 tokenId = currentSalesIndex();
            _mint(_msgSender(), tokenId);
            _setTokenURI(tokenId, string(abi.encodePacked(salesInfo().baseURIforMinting, Strings.toString(tokenId), ".json")));
            _addSalesIndex();
        }
    }
}