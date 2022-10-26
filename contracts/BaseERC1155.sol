// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract BaseERC1155 is Initializable, ERC1155URIStorageUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenTracker;
    
    string public name;

     /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}
    
    function initialize(string memory name_, string memory uri_) public initializer {
        __ERC1155URIStorage_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        _setBaseURI(uri_);
        name = name_;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function mint(address to, uint256 amount, string memory tokenURI) public {
        uint256 id = _tokenTracker.current();
        _mint(to, id, amount, "");
        _setURI(id, tokenURI);  
        _tokenTracker.increment();
    }

    function getCurrentTokenId() public view returns(uint256) {
        return _tokenTracker.current();
    }

    function incrementTokenId() internal {
        _tokenTracker.increment();
    }
    
}