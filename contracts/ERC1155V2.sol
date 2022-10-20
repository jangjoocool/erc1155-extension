// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./BaseERC1155.sol";
import "./lib/ERC5192.sol";

contract ERC1155V2 is BaseERC1155, ERC5192 {
    function burn(address from, uint256 id, uint256 amount) public onlyOwner {
        _burn(from, id, amount);
    }

    function mintAndLock(address to, uint256 amount, string memory tokenURI) public onlyOwner {
        uint256 id = getCurrentTokenId();
        _mint(to, id, amount, "");
        _setURI(id, tokenURI);
        incrementTokenId();
        lock(id);
    }

    function lock(uint256 tokenId) public virtual override onlyOwner {
        _lock(tokenId);
    }

    function unlock(uint256 tokenId) public virtual override onlyOwner {
        _unlock(tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override isLocked(id) {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }
}