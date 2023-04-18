// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "test/mock/ERCNMetadataMock.sol";

contract ERCNMetadataTest is Test {
    ERCNMetadataMock ercn;

    error InvalidId(uint256 id);

    function setUp() public {
        ercn = new ERCNMetadataMock();
    }

    function testName() public {
        assertEq(ercn.name(), "Example ERCN Metadata");
    }

    function testSymbol() public {
        assertEq(ercn.symbol(), "EEM");
    }

    function testTokenURI() public {
        ercn.mint(vm.addr(1), 1, 1);
        assertEq(ercn.tokenURI(1), "<base_uri>/1");
    }

    function testTokenURIInvalidId() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidId.selector, (1)));
        ercn.tokenURI(1);
    }
}
