// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/ERCNMetadata.sol";

contract ERCNMetadataMock is ERCNMetadata {
    constructor() ERCNMetadata() {}

    function mint(address owner, uint256 id, uint256 amount) public {
        balanceOf[owner][id] += amount;
        totalSupply[id] += amount;
        emit Transfer(address(0), owner, id, amount);
    }
}
