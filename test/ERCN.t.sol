// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "test/mock/ERCNMock.sol";

contract ERCNTest is Test {
    ERCNMock ercn;
    address alice = vm.addr(1);
    address bob = vm.addr(2);
    uint256 tokenId = 1;
    uint256 amount = 100;

    error InsufficientBalance(address owner, uint256 id);
    error InsufficientPermission(address spender, uint256 id);

    event Transfer(address indexed sender, address indexed receiver, uint256 indexed id, uint256 amount);

    event OperatorSet(address indexed owner, address indexed spender, bool approved);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id, uint256 amount);

    function setUp() public {
        ercn = new ERCNMock();

        ercn.mint(alice, 1, 1);
    }

    function testTotalSupply() public {
        assertEq(ercn.totalSupply(tokenId), 1);
    }

    function testDecimals() public {
        assertEq(ercn.decimals(tokenId), 0);

        ercn.setDecimals(tokenId, 18);

        assertEq(ercn.decimals(tokenId), 18);
    }

    function testBalanceOf() public {
        assertEq(ercn.balanceOf(alice, tokenId), 1);
        assertEq(ercn.balanceOf(bob, tokenId), 0);
    }

    function testAllowance() public {
        assertEq(ercn.allowance(alice, bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, tokenId, 1);

        vm.prank(alice);
        ercn.approve(bob, tokenId, 1);

        assertEq(ercn.allowance(alice, bob, tokenId), 1);
    }

    function testTransfer() public {
        assertEq(ercn.balanceOf(alice, tokenId), 1);
        assertEq(ercn.balanceOf(bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, tokenId, 1);

        vm.prank(alice);
        ercn.transfer(bob, tokenId, 1);

        assertEq(ercn.balanceOf(alice, tokenId), 0);
        assertEq(ercn.balanceOf(bob, tokenId), 1);
    }

    function testTransferFrom() public {
        assertEq(ercn.balanceOf(alice, tokenId), 1);
        assertEq(ercn.balanceOf(bob, tokenId), 0);
        assertEq(ercn.allowance(alice, bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, tokenId, 1);

        vm.prank(alice);
        ercn.approve(bob, tokenId, 1);
        vm.prank(bob);
        ercn.transferFrom(alice, bob, tokenId, 1);

        assertEq(ercn.balanceOf(alice, tokenId), 0);
        assertEq(ercn.balanceOf(bob, tokenId), 1);
        assertEq(ercn.allowance(alice, bob, tokenId), 0);
    }

    function testTransferFromCallerIsSpender() public {
        assertEq(ercn.balanceOf(alice, tokenId), 1);
        assertEq(ercn.balanceOf(bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, tokenId, 1);

        vm.prank(alice);
        ercn.transferFrom(alice, bob, tokenId, 1);

        assertEq(ercn.balanceOf(alice, tokenId), 0);
        assertEq(ercn.balanceOf(bob, tokenId), 1);
    }

    function testTransferFromCallerIsOperator() public {
        assertEq(ercn.balanceOf(alice, tokenId), 1);
        assertEq(ercn.balanceOf(bob, tokenId), 0);
        assertFalse(ercn.isOperator(alice, bob));
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, tokenId, 1);

        vm.prank(alice);
        ercn.setOperator(bob, true);
        vm.prank(bob);
        ercn.transferFrom(alice, bob, tokenId, 1);

        assertEq(ercn.balanceOf(alice, tokenId), 0);
        assertEq(ercn.balanceOf(bob, tokenId), 1);
        assertTrue(ercn.isOperator(alice, bob));
    }

    function testApprove() public {
        assertEq(ercn.allowance(alice, bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, tokenId, 1);

        vm.prank(alice);
        ercn.approve(bob, tokenId, 1);

        assertEq(ercn.allowance(alice, bob, tokenId), 1);
    }

    function testSetOperator() public {
        assertFalse(ercn.isOperator(alice, bob));
        vm.expectEmit(true, true, true, true);
        emit OperatorSet(alice, bob, true);

        vm.prank(alice);
        ercn.setOperator(bob, true);

        assertTrue(ercn.isOperator(alice, bob));
    }

    function testTransferInsufficientBalance() public {
        assertEq(ercn.balanceOf(alice, tokenId), 1);
        assertEq(ercn.balanceOf(bob, tokenId), 0);
        vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector, alice, tokenId));

        vm.prank(alice);
        ercn.transfer(bob, tokenId, 2);
    }

    function testTransferFromInsufficientBalance() public {
        assertEq(ercn.balanceOf(alice, tokenId), 1);
        assertEq(ercn.balanceOf(bob, tokenId), 0);
        vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector, alice, tokenId));

        vm.prank(alice);
        ercn.transferFrom(alice, bob, tokenId, 2);
    }

    function testTransferFromInsufficientPermission() public {
        assertEq(ercn.balanceOf(alice, tokenId), 1);
        assertEq(ercn.balanceOf(bob, tokenId), 0);
        assertEq(ercn.allowance(alice, bob, tokenId), 0);
        vm.expectRevert(abi.encodeWithSelector(InsufficientPermission.selector, bob, tokenId));

        vm.prank(bob);
        ercn.transferFrom(alice, bob, tokenId, 1);
    }
}
