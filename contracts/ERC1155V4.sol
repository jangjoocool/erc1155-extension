// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC1155V3.sol";
import "./lib/IERC5006.sol";
import '@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol';

contract ERC1155V4 is ERC1155V3 {
    struct TokenInfo {
        string baseURI;
        uint initTimeStamp;
        uint interval;
    }

    // using EnumerableSetUpgradeable for EnumerableSetUpgradeable
    
    mapping(uint256 => TokenInfo) private tokenInfo;

    event updateNFT (uint256 tokenId, string tokenURI);

    function updateTokenURI() external virtual {
        for(uint256 i = 0; i < getCurrentTokenId(); i++) {
            if(tokenInfo[i].initTimeStamp > 0
                && (block.timestamp - tokenInfo[i].initTimeStamp) > tokenInfo[i].interval) {
                string memory newURI = string(abi.encodePacked(tokenInfo[i].baseURI, "/1.json"));
                _setURI(i, newURI);
                emit updateNFT(i, uri(i));
            }
        }
    }

    function setTokenInfo(uint256 tokenId, string memory baseURI, uint interval) internal virtual {
        tokenInfo[tokenId].baseURI = baseURI;
        tokenInfo[tokenId].initTimeStamp = block.timestamp;
        tokenInfo[tokenId].interval = interval;
    }
    
    function mintForDynamic(address to, uint256 amount, string memory tokenURI, uint interval) public virtual onlyOwner {
        uint256 id = getCurrentTokenId();
        _mint(to, id, amount, "");
        _setURI(id, string(abi.encodePacked(tokenURI, "/0.json")));  
        setTokenInfo(id, tokenURI, interval);
        incrementTokenId();
    }

    function getTokenInfo(uint256 tokenId) public view returns(TokenInfo memory) {
        return tokenInfo[tokenId];
    }

    function version() public pure virtual override returns(string memory) { return "4.0.0"; }
}