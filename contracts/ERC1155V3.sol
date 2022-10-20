// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC1155V2.sol";

contract ERC1155V3 is ERC1155V2 {
    function version() public pure virtual returns(string memory) { return "3.0.0"; }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        
        for(uint256 i = 0; i < ids.length; i++) {
            if(locked(ids[i])) {
                delete ids[i];
                delete amounts[i];
            }
        }
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}