// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/forge-std/src/Test.sol";
import "./mock/ERC6909ContentURIMock.sol";

contract ERC6909ContentURITest is Test {
    ERC6909ContentURIMock erc6909;

    function setUp() public {
        erc6909 = new ERC6909ContentURIMock();
    }

    function testContractURI() public {
        assertEq(erc6909.contractURI(), "");
        erc6909.setContractURI("Example URI");
        assertEq(erc6909.contractURI(), "Example URI");
    }

    function testTokenURI() public {
        assertEq(erc6909.tokenURI(0), "<baseuri>/{id}");
        assertEq(erc6909.tokenURI(1), "<baseuri>/{id}");
    }
}
