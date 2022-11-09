// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./lib/upgradeable/WhitelistUpgradeable.sol";
import "./lib/upgradeable/MintingUpgradeable.sol";

contract GenesisNFTUpgradeable is Initializable, ERC721URIStorageUpgradeable, OwnableUpgradeable, WhitelistUpgradeable, MintingUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenTracker;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(string memory name_, string memory symbol_) public initializer {
        __ERC721_init(name_, symbol_);
        __ERC721URIStorage_init();
        __Ownable_init();
        __Whitelist_init();
        __Minting_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

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
            _setTokenURI(tokenId, string(abi.encodePacked(mintingInfo().baseURIforMinting, StringsUpgradeable.toString(tokenId), ".json")));
            _addMintingIndex();
        }
        _setLastCallBlockNumber();
    }
}