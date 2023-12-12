// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/ERC6909Metadata.sol";

contract ERC6909MetadataMock is ERC6909Metadata {
    constructor() ERC6909Metadata() {}

    function setName(uint256 id, string memory _name) public {
        name[id] = _name;
    }

    function setSymbol(uint256 id, string memory _symbol) public {
        symbol[id] = _symbol;
    }

    function setDecimals(uint256 id, uint8 amount) public {
        decimals[id] = amount;
    }
}
