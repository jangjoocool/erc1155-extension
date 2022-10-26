// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DynamicHandlerOrigin is Ownable {
    mapping(uint256 => DynamicInfo) private dynamicInfo;

    struct DynamicInfo {
        uint256 idx;
        uint interval;
        uint lastBlockTimestamp;
    }

    event ChangeDynamicInfo(uint256 tokenId, DynamicInfo dynamicInfo);

    function getDynamicInfo(uint256 tokenId) public view returns(DynamicInfo memory) {
        return dynamicInfo[tokenId];
    }

    function setDynamicInfo(uint256 tokenId) public {
        uint tmp = dynamicInfo[tokenId].lastBlockTimestamp;
        dynamicInfo[tokenId].lastBlockTimestamp = block.timestamp;

        if(tmp > 0) {
            dynamicInfo[tokenId].idx += 1;
            dynamicInfo[tokenId].interval *= 2;
        } else {
            dynamicInfo[tokenId].interval = 600;
        }
        emit ChangeDynamicInfo(tokenId, dynamicInfo[tokenId]);
    }

    function oracleHandler(uint256 tokenId) external onlyOwner {
        require(
            block.timestamp - dynamicInfo[tokenId].lastBlockTimestamp > dynamicInfo[tokenId].interval,
            "The interval has not yet been exceeded."
        );
        setDynamicInfo(tokenId);
    }
}