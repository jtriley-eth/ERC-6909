// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "test/mock/ERC6909MetadataMock.sol";

contract ERC6909MetadataTest is Test {
    ERC6909MetadataMock erc6909;
    uint256 tokenId = 1;

    error InvalidId(uint256 id);

    function setUp() public {
        erc6909 = new ERC6909MetadataMock();
    }

    function testName() public {
        assertEq(erc6909.name(), "Example ERC6909 Metadata");
    }

    function testSymbol() public {
        assertEq(erc6909.symbol(), "EEM");
    }

    function testTokenURI() public {
        erc6909.mint(vm.addr(1), 1, 1);
        assertEq(erc6909.tokenURI(1), "<base_uri>/1");
    }

    function testTokenURIInvalidId() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidId.selector, (1)));
        erc6909.tokenURI(1);
    }

    function testDecimals() public {
        assertEq(erc6909.decimals(tokenId), 0);

        erc6909.setDecimals(tokenId, 18);

        assertEq(erc6909.decimals(tokenId), 18);
    }
}
