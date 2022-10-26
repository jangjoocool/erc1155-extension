// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC1155-dynamic.sol";

contract ERC1155DynamicV2 is ERC1155Dynamic {
    function version() external pure virtual override returns(string memory) { return "3.0.0"; }
}