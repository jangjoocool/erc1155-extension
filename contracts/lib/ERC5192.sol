// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "./IERC5192.sol";

contract ERC5192 is IERC5192 {
    mapping(uint256 => bool) isLock;

    modifier isLocked(uint256 tokenId) {
        require(
            !isLock[tokenId],
            "ERC5192: token id locked."
        );
        _;
    }

    function _lock(uint256 tokenId) internal {
        isLock[tokenId] = true;
        emit Locked(tokenId);
    }

    function _unlock(uint256 tokenId) internal {
        isLock[tokenId] = false;
        emit Unlocked(tokenId);
    }

    function lock(uint256 tokenId) public virtual {
        _lock(tokenId);
    }

    function unlock(uint256 tokenId) public virtual {
        _unlock(tokenId);
    }

    function locked(uint256 tokenId) public view virtual override returns(bool) {
        return isLock[tokenId];
    }
}