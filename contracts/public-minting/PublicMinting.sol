// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../BaseERC1155.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract PublicMinting is BaseERC1155 {
    using SafeMathUpgradeable for uint256;

    // To prevent bot attack, we record the last contract call block number.
    mapping (address => uint256) private _lastCallBlockNumber;
    uint256 private _antibotInterval;

    // If someone burns NFT in the middle of minting,
    // the tokenId will go wrong, so use the index instead of totalSupply().
    uint256 private _mintIndexForSale;
    uint256 private _mintLimitPerBlock;           // Maximum purchase nft per person per block
    uint256 private _mintLimitPerSale;            // Maximum purchase nft per person per sale

    string  private _tokenBaseURI;
    uint256 private _mintStartBlockNumber;        // In blockchain, blocknumber is the standard of time.
    uint256 private _maxSaleAmount;               // Maximum purchase volume of normal sale.
    uint256 private _mintPrice;                   // 1 MATIC = 1000000000000000000
    uint256 private _mintPriceWeth;               // 1 WETH = 1000000000000000000

    address payable private _payCollector;
    IERC20Upgradeable private _acceptedToken;

    function mintingInfomation() external view returns (uint256[7] memory) {
        uint256[7] memory info = [
            _antibotInterval,
            _mintIndexForSale,
            _mintLimitPerBlock,
            _mintLimitPerSale,
            _mintStartBlockNumber,
            _maxSaleAmount,
            _mintPrice
        ];
        return info;
    }

    function withdraw() external onlyOwner {
        _payCollector.transfer(address(this).balance);
        _acceptedToken.transfer(_payCollector, _acceptedToken.balanceOf(address(this)));
    }

    function publicMint(uint256 requestedCount) external payable {
        require(_lastCallBlockNumber[_msgSender()].add(_antibotInterval) < block.number, "Bot is not allowed");
        require(block.number >= _mintStartBlockNumber, "Not yet started");
        require(requestedCount > 0 && requestedCount <= _mintLimitPerBlock, "Too many requests or zero request");
        require(_mintIndexForSale.add(requestedCount) <= _maxSaleAmount, "Exceed max amount");
        // require(balanceOf(_msgSender()) + requestedCount <= _mintLimitPerSale, "Exceed max amount per person");

        payWithMatic(requestedCount);

        for(uint256 i = 0; i < requestedCount; i++) {
            _mint(_msgSender(), _mintIndexForSale, 1, "");
            _setURI(_mintIndexForSale,
                            string(abi.encodePacked(_tokenBaseURI, _mintIndexForSale, ".json")));
            _mintIndexForSale = _mintIndexForSale.add(1);
        }
        _lastCallBlockNumber[_msgSender()] = block.number;
    }

    function payWithMatic(uint256 requestedCount) public payable {
        require(msg.value == _mintPrice.mul(requestedCount), "Not enough MATIC");
    }

    function payWithWeth(uint256 requestedCount, uint256 price) public {
        require(price == _mintPriceWeth.mul(requestedCount), "Not enough WETH");
        require(_acceptedToken.transferFrom(_msgSender(), 0x1D8A98BB361e01851e551FD9515Fa7716Dd30E0f, price));
    }

    function setupSale(uint256 newAntibotInterval, 
                       uint256 newMintIndexForSale,
                       uint256 newMintLimitPerBlock,
                       uint256 newMintLimitPerSale,
                       string calldata newTokenBaseURI, 
                       uint256 newMintStartBlockNumber,
                       uint256 newMaxSaleAmount,
                       uint256 newMintPrice,
                       uint256 newMintPriceWeth) external onlyOwner {
      _antibotInterval = newAntibotInterval;
      _mintIndexForSale = newMintIndexForSale;
      _mintLimitPerBlock = newMintLimitPerBlock;
      _mintLimitPerSale = newMintLimitPerSale;
      _tokenBaseURI = newTokenBaseURI;
      _mintStartBlockNumber = newMintStartBlockNumber;
      _maxSaleAmount = newMaxSaleAmount;
      _mintPrice = newMintPrice;
      _mintPriceWeth = newMintPriceWeth;
    }

    function setPayCollector(address payCollector) public onlyOwner {
        _payCollector = payable(payCollector);
    }

    function setAcceptedToken(address acceptedToken) public onlyOwner {
        _acceptedToken = IERC20Upgradeable(acceptedToken);
    }
}