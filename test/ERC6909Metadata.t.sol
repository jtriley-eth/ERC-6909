// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/forge-std/src/Test.sol";
import "./mock/ERC6909MetadataMock.sol";

contract ERC6909MetadataTest is Test {
    ERC6909MetadataMock erc6909;
    uint256 tokenId = 1;

    error InvalidId(uint256 id);

    function setUp() public {
        erc6909 = new ERC6909MetadataMock();
    }

    function testName() public {
        assertEq(erc6909.name(tokenId), "");
        erc6909.setName(tokenId, "Example Token Name");
        assertEq(erc6909.name(tokenId), "Example Token Name");
    }

    function testSymbol() public {
        assertEq(erc6909.symbol(tokenId), "");
        erc6909.setSymbol(tokenId, "ETS");
        assertEq(erc6909.symbol(tokenId), "ETS");
    }

    function testDecimals() public {
        assertEq(erc6909.decimals(tokenId), 0);

        erc6909.setDecimals(tokenId, 18);

        assertEq(erc6909.decimals(tokenId), 18);
    }

    function testFuzzName(uint256 id, string memory name) public {
        assertEq(erc6909.name(id), "");

        erc6909.setName(id, name);

        assertEq(erc6909.name(id), name);
    }

    function testFuzzSymbol(uint256 id, string memory symbol) public {
        assertEq(erc6909.symbol(id), "");

        erc6909.setSymbol(id, symbol);

        assertEq(erc6909.symbol(id), symbol);
    }

    function testFuzzDecimals(uint256 id, uint8 decimals) public {
        assertEq(erc6909.decimals(id), 0);

        erc6909.setDecimals(id, decimals);

        assertEq(erc6909.decimals(id), decimals);
    }
}
