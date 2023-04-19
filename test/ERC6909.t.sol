// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "test/mock/ERC6909Mock.sol";

contract erc6909Test is Test {
    ERC6909Mock erc6909;
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
        erc6909 = new ERC6909Mock();

        erc6909.mint(alice, 1, 1);
    }

    function testTotalSupply() public {
        assertEq(erc6909.totalSupply(tokenId), 1);
    }

    function testDecimals() public {
        assertEq(erc6909.decimals(tokenId), 0);

        erc6909.setDecimals(tokenId, 18);

        assertEq(erc6909.decimals(tokenId), 18);
    }

    function testBalanceOf() public {
        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
    }

    function testAllowance() public {
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, tokenId, 1);

        vm.prank(alice);
        erc6909.approve(bob, tokenId, 1);

        assertEq(erc6909.allowance(alice, bob, tokenId), 1);
    }

    function testTransfer() public {
        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, tokenId, 1);

        vm.prank(alice);
        erc6909.transfer(bob, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
    }

    function testTransferFrom() public {
        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, tokenId, 1);

        vm.prank(alice);
        erc6909.approve(bob, tokenId, 1);
        vm.prank(bob);
        erc6909.transferFrom(alice, bob, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
    }

    function testTransferFromCallerIsSpender() public {
        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, tokenId, 1);

        vm.prank(alice);
        erc6909.transferFrom(alice, bob, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
    }

    function testTransferFromCallerIsOperator() public {
        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        assertFalse(erc6909.isOperator(alice, bob));
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, tokenId, 1);

        vm.prank(alice);
        erc6909.setOperator(bob, true);
        vm.prank(bob);
        erc6909.transferFrom(alice, bob, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
        assertTrue(erc6909.isOperator(alice, bob));
    }

    function testApprove() public {
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, tokenId, 1);

        vm.prank(alice);
        erc6909.approve(bob, tokenId, 1);

        assertEq(erc6909.allowance(alice, bob, tokenId), 1);
    }

    function testSetOperator() public {
        assertFalse(erc6909.isOperator(alice, bob));
        vm.expectEmit(true, true, true, true);
        emit OperatorSet(alice, bob, true);

        vm.prank(alice);
        erc6909.setOperator(bob, true);

        assertTrue(erc6909.isOperator(alice, bob));
    }

    function testTransferInsufficientBalance() public {
        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector, alice, tokenId));

        vm.prank(alice);
        erc6909.transfer(bob, tokenId, 2);
    }

    function testTransferFromInsufficientBalance() public {
        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector, alice, tokenId));

        vm.prank(alice);
        erc6909.transferFrom(alice, bob, tokenId, 2);
    }

    function testTransferFromInsufficientPermission() public {
        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
        vm.expectRevert(abi.encodeWithSelector(InsufficientPermission.selector, bob, tokenId));

        vm.prank(bob);
        erc6909.transferFrom(alice, bob, tokenId, 1);
    }

    function testSupportsInterface() public {
        // type(Ierc6909).interfaceId
        // type(IERC165).interfaceId
        assertTrue(erc6909.supportsInterface(0x8da179e8));
        assertTrue(erc6909.supportsInterface(0x01ffc9a7));
    }
}
