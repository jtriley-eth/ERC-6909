// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/ERC6909ContentURI.sol";

contract ERC6909ContentURIMock is ERC6909ContentURI {
    function setContractURI(string memory uri) public {
        contractURI = uri;
    }
}
