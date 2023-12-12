// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/ERC6909TokenSupply.sol";

contract ERC6909TokenSupplyMock is ERC6909TokenSupply {
    function mint(address receiver, uint256 id, uint256 amount) public {
        balanceOf[receiver][id] += amount;
        totalSupply[id] += amount;
        emit Transfer(msg.sender, address(0), receiver, id, amount);
    }

    function burn(address receiver, uint256 id, uint256 amount) public {
        balanceOf[receiver][id] -= amount;
        totalSupply[id] -= amount;
        emit Transfer(msg.sender, receiver, address(0), id, amount);
    }
}
