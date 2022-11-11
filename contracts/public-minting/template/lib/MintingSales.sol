// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract MintingSales is Context {
    using SafeMath for uint256;

    // To prevent bot attack, we record the last contract call block number.
    mapping (address => uint256) private _lastCallBlockNumber;
    address payable private _collector;
    uint256 private _salesIndex;
    SalesInfo private _salesInfo;

    struct SalesInfo {
        uint256 antibotInterval;       // Interval block count to prevent bot attack
        uint256 mintLimitPerOnce;      // Limit per once for minting
        uint256 mintLimitPerAccount;   // Limit per account for minting
        uint256 mintStartBlockNumber;  // Start block number of minting
        uint256 mintEndBlockNumber;    // End block number of minting
        uint256 mintStartIndex;        // First index for minting
        uint256 maxMintingAmount;      // Maximum volume of minting
        uint256 mintPrice;             // price per 1 NFT for minting(1 MATIC = 1000000000000000000)
        string baseURIforMinting;      // Base URI for minting
    }

    /**
     * @dev Emitted when withdraw payment.
     * @param to The address to receive payment.
     * @param amount A mount of send to collector.
     */
    event Withdraw(address to, uint256 amount);

    /**
     * @dev Emitted when set up a minting sales.
     * @param salesInfo The minting sales info.
     */
    event SetupSales(SalesInfo salesInfo);

    modifier blockNumberValidator() {
        require(block.number >= _salesInfo.mintStartBlockNumber, "Sales: not yet started");
        if (_salesInfo.mintEndBlockNumber > 0) {
            require(block.number <= _salesInfo.mintEndBlockNumber, "Sales: has ended");
        }
        _;
    }

    modifier salesValidator(uint256 requestedCount, uint256 balance) {
        require(block.number > _lastCallBlockNumber[_msgSender()].add(_salesInfo.antibotInterval), "Sales: bot is not allowed");
        require(_salesIndex < _salesInfo.mintStartIndex.add(_salesInfo.maxMintingAmount), "Sales: sold out");
        require(requestedCount > 0 && requestedCount <= _salesInfo.mintLimitPerOnce, "Sales: too many request or zero request");
        require(msg.value == _salesInfo.mintPrice.mul(requestedCount), "Sales: not enough MATIC");
        require(balance.add(requestedCount) <= _salesInfo.mintLimitPerAccount, "Sales: exceed max amount per account");
        _;
    }

    /**
     * @dev Returns minting info.
     */
    function salesInfo() public view virtual returns(SalesInfo memory) {
        return _salesInfo;
    }

    /**
     * @dev Returns current minting index.
     */
    function currentSalesIndex() public view virtual returns(uint256) {
        return _salesIndex;
    }

    /**
     * @dev Add minting index.
     */
    function _addSalesIndex() internal virtual {
        _salesIndex = _salesIndex.add(1);
    }

    /**
     * @dev Set last call block number of sender.
     */
    function _setLastCallBlockNumber() internal virtual {
        _lastCallBlockNumber[_msgSender()] = block.number;
    }

    /**
     * @dev Withdraw payment to collector.
     */
    function _withdraw() internal virtual {
        require(_collector != address(0), "Minting: collector is not exist");
        uint256 amount = address(this).balance;
        require(amount > 0, "Minting: contract's MATIC balance is zero");
        _collector.transfer(amount);
        emit Withdraw(_collector, amount);
    }

    /**
     * @dev Set a payment address.
     * @param addr The address to receive payment.
     */
    function _setCollector(address addr) internal virtual {
        require(_collector != addr, "Minting: address is already collector");
        _collector = payable(addr);
    }

    /**
     * @dev Set Minting options.
     * @param antibotInterval Interval block count to prevent bot attack.
     * @param mintLimitPerOnce Limit per once for minting.
     * @param mintLimitPerAccount Limit per account for minting.
     * @param mintStartBlockNumber Start block number of minting.
     * @param mintEndBlockNumber End block number of minting.
     * @param mintStartIndex First index for minting.
     * @param maxMintingAmount Maximum volume of minting.
     * @param mintPrice price per 1 NFT for minting(1 MATIC = 1000000000000000000).
     * @param baseURIforMinting Base URI for minting.
     */
    function _setupSales(
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
        internal virtual
    {
        _salesInfo = SalesInfo(
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
        _salesIndex = mintStartIndex;
        emit SetupSales(_salesInfo);
    }
}