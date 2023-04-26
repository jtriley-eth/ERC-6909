// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/ERC6909Metadata.sol";

contract ERC6909MetadataMock is ERC6909Metadata {
    constructor() ERC6909Metadata() {}

    function mint(address owner, uint256 id, uint256 amount) public {
        balanceOf[owner][id] += amount;
        totalSupply[id] += amount;
        emit Transfer(address(0), owner, id, amount);
    }

    function setDecimals(uint256 id, uint8 amount) public {
        decimals[id] = amount;
    }
}
