// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/ERCN.sol";

contract ERCNMock is ERCN {
    constructor() ERCN() {}

    function mint(address owner, uint256 id, uint256 amount) public {
        balanceOf[owner][id] += amount;
        totalSupply[id] += amount;
        emit Transfer(address(0), owner, id, amount);
    }
}