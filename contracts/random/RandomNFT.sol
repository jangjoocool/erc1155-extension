// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../lib/ERC721R.sol";

contract RandomNFT is ERC721r {
    // 10_000 is the number of tokens in the colletion
    constructor() ERC721r("randomNFT", "RNFT", 50) {}
    
    function mint(uint quantity) public {
        _mintRandom(msg.sender, quantity);
    }
}