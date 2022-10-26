// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../BaseERC1155.sol";
import "./DynamicHandlerOrigin.sol";

contract ERC1155Dynamic is BaseERC1155 {
    DynamicHandlerOrigin dynamic;
    mapping(uint256 => string[]) private dynamicURIs;

    function existing(address addr) public onlyOwner {
        dynamic = DynamicHandlerOrigin(addr);
    }

    function mintForDynamic(address to, uint256 amount, string[] memory tokenURIs) public virtual {
        uint256 id = getCurrentTokenId();
        _mint(to, id, amount, "");
        dynamicURIs[id] = tokenURIs;
        dynamic.setDynamicInfo(id);
        incrementTokenId();
    }

    function uri(uint256 tokenId) public view override returns(string memory) {
        uint256 idx = dynamic.getDynamicInfo(tokenId).idx;
        return dynamicURIs[tokenId][idx];
    }

    function version() external pure virtual returns(string memory) { return "2.0.0"; }
}