// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/ERC6909.sol";

contract ERC6909Mock is ERC6909 {
    constructor() ERC6909() {}

    function mint(address owner, uint256 id, uint256 amount) public {
        balanceOf[owner][id] += amount;
        totalSupply[id] += amount;
        emit Transfer(address(0), owner, id, amount);
    }
}
