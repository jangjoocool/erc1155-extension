// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./BaseERC1155.sol";

contract ERC1155Dynamic is BaseERC1155 {
    mapping(uint256 => string[]) private dynamicURIs;

    function version() external pure virtual returns(string memory) { return "2.0.0"; }

    function mintForDynamic(address to, uint256 amount, string[] memory tokenURIs) public virtual {
        uint256 id = getCurrentTokenId();
        _mint(to, id, amount, "");
        _setURI(id, tokenURIs[0]);
        dynamicURIs[id] = tokenURIs;  
        incrementTokenId();
    }

    function setNextURI(uint256 tokenId) public virtual onlyOwner {
        string[] memory dynamicURIs_ = _dynamicURIs(tokenId);
        uint256 idx = indexOf(dynamicURIs_, uri(tokenId)) + 1;
        string memory newURI = bytes(dynamicURIs_[idx]).length > 0 ? dynamicURIs_[idx] : dynamicURIs_[idx-1];
        _setURI(tokenId, newURI);
    }

    function _dynamicURIs(uint256 tokenId) public view returns(string[] memory) {
        return dynamicURIs[tokenId];
    }

    function indexOf(string[] memory arr, string memory searchFor) internal pure returns (uint256) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (keccak256(abi.encodePacked(arr[i])) == keccak256(abi.encodePacked(searchFor))) {
                return i;
            }
        }
        revert("Not Found");
    }
}