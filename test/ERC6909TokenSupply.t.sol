// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./mock/ERC6909TokenSupplyMock.sol";
import "../lib/forge-std/src/Test.sol";

contract ERC6909TokenSupplyTest is Test {
    ERC6909TokenSupplyMock erc6909;

    function setUp() public {
        erc6909 = new ERC6909TokenSupplyMock();
    }

    function testTotalSupply() public {
        assertEq(erc6909.totalSupply(0), 0);

        erc6909.mint(address(this), 0, 1);

        assertEq(erc6909.totalSupply(0), 1);

        erc6909.burn(address(this), 0, 1);

        assertEq(erc6909.totalSupply(0), 0);
    }

    function testFuzzTotalSupply(address receiver, uint256 id, uint256 mintAmount, uint256 burnAmount) public {
        burnAmount = bound(burnAmount, 0, mintAmount);

        assertEq(erc6909.totalSupply(id), 0);

        erc6909.mint(receiver, id, mintAmount);

        assertEq(erc6909.totalSupply(id), mintAmount);

        erc6909.burn(receiver, id, burnAmount);

        assertEq(erc6909.totalSupply(id), mintAmount - burnAmount);
    }
}
