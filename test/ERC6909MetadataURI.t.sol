// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/forge-std/src/Test.sol";
import "../src/ERC6909MetadataURI.sol";

contract ERC6909MetadataURITest is Test {
    ERC6909MetadataURI erc6909;

    function setUp() public {
        erc6909 = new ERC6909MetadataURI();
    }

    function testTokenURI() public {
        assertEq(erc6909.tokenURI(0), "<baseuri>/{id}");
        assertEq(erc6909.tokenURI(1), "<baseuri>/{id}");
    }
}
