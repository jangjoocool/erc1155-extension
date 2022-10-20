// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./BaseERC1155.sol";

contract ERC1155V2Test is BaseERC1155 {
    function version() external pure virtual returns(string memory) { return "2.0.0"; }

    function mintBatch(address to, uint256[] memory amounts, string[] memory tokenURIs) public virtual {
        uint256[] memory ids = new uint256[](amounts.length);
        for(uint256 i = 0; i < amounts.length; i++) {
            ids[i] = getCurrentTokenId();
            incrementTokenId();
            _setURI(ids[i], tokenURIs[i]);
        }
        _mintBatch(to, ids, amounts, "");
    }
}