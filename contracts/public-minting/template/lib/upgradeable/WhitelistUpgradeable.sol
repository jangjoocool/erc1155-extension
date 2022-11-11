// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

abstract contract WhitelistUpgradeable is Initializable, ContextUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    EnumerableSetUpgradeable.AddressSet private _whitelist;

    /**
     * @dev Emitted when adding whitelist.
     * @param addr The address to add in whitelist.
     */
    event AddWhiteList(address addr);

    /**
     * @dev Emitted when removing whitelist.
     * @param addr The address to remove in whitelist.
     */
    event RemoveWhiteList(address addr);

    /**
     * @dev Emitted when adding whitelist for batch.
     * @param addrs a batch of addresses to add in whitelist.
     */
    event AddWhiteListBatch(address[] addrs);

    /**
     * @dev Emitted when removing whitelist for batch.
     * @param addrs a batch of addresses to remove in whitelist.
     */
    event RemoveWhiteListBatch(address[] addrs);

    function __Whitelist_init() internal onlyInitializing {}

    function __Whitelist_init_unchained() internal onlyInitializing {}

    /**
     * @dev Throws if called by any account other than the whitlist.
     */
    modifier onlyWhitelist() {
        _checkWhitelist();
        _;
    }

    /**
     * @dev Returns all addresses in the whitelist.
     */
    function allWhitelist() public view virtual returns(address[] memory) {
        return _whitelist.values();
    }

    /**
     * @dev Throw if the sender is not the whitlist.
     */
    function _checkWhitelist() internal virtual {
        require(_whitelist.contains(_msgSender()), "Whitelist: caller is not the whitelist");
    }

    /**
     * @dev Add a address in whitelist.
     * @param addr The address to add in whitelist.
     */
    function _addWhitelist(address addr) internal virtual {
        require(addr != address(0), "Whitelist: address is tho zero address");
        require(!_whitelist.contains(addr), "Whitelist: address is already in the whitelist");
        _whitelist.add(addr);
        emit AddWhiteList(addr);
    }

    /**
     * @dev Remove a address in whitelist.
     * @param addr The address to remove in whitelist.
     */
    function _removeWhitelist(address addr) internal virtual {
        require(_whitelist.contains(addr), "Whitelist: address is not the whitelist");
        _whitelist.remove(addr);
        emit RemoveWhiteList(addr);
    }

    /**
     * @dev add a batch of addresses in whitelist.
     * @param addrs a batch of addresses to add in whitelist.
     */
    function _addWhitelistBatch(address[] memory addrs) internal virtual {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != address(0), "Whitelist: address is tho zero address");
            require(!_whitelist.contains(addr), "Whitelist: address is already in the whitelist");
            _whitelist.add(addr);
        }
        emit AddWhiteListBatch(addrs);
    }

    /**
     * @dev remove a batch of addresses in whitelist.
     * @param addrs a batch of addresses to remove in whitelist.
     */
    function _removeWhitelistBatch(address[] memory addrs) internal virtual {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(_whitelist.contains(addr), "Whitelist: address is not the whitelist");
            _whitelist.remove(addr);
        }
        emit RemoveWhiteListBatch(addrs);
    }
}