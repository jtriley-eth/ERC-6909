// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./mock/ERC6909Mock.sol";

contract ERC6909Test is Test {
    ERC6909Mock erc6909;
    address alice = vm.addr(1);
    address bob = vm.addr(2);
    uint256 tokenId = 1;
    uint256 amount = 100;

    error InsufficientBalance();
    error InsufficientPermission();

    event Transfer(
        address caller, address indexed sender, address indexed receiver, uint256 indexed id, uint256 amount
    );

    event OperatorSet(address indexed owner, address indexed spender, bool approved);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id, uint256 amount);

    function setUp() public {
        erc6909 = new ERC6909Mock();
    }

    // ---------------------------------------------------------------------------------------------
    // Success Cases

    function testTotalSupply() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.totalSupply(tokenId), 1);
    }

    function testBalanceOf() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
    }

    function testAllowance() public {
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Approval(alice, bob, tokenId, 1);

        vm.prank(alice);
        erc6909.approve(bob, tokenId, 1);

        assertEq(erc6909.allowance(alice, bob, tokenId), 1);
    }

    function testTransfer() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(alice, alice, bob, tokenId, 1);

        vm.prank(alice);
        assertTrue(erc6909.transfer(bob, tokenId, 1));
        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
    }

    function testTransferFrom() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
        vm.prank(alice);
        erc6909.approve(bob, tokenId, 1);

        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(bob, alice, bob, tokenId, 1);

        vm.prank(bob);
        assertTrue(erc6909.transferFrom(alice, bob, tokenId, 1));
        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
    }

    function testTransferFromInfiniteAllowance() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
        vm.prank(alice);
        erc6909.approve(bob, tokenId, type(uint256).max);

        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(bob, alice, bob, tokenId, 1);

        vm.prank(bob);
        erc6909.transferFrom(alice, bob, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
        assertEq(erc6909.allowance(alice, bob, tokenId), type(uint256).max);
    }

    function testTransferFromCallerIsSender() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(alice, alice, bob, tokenId, 1);

        vm.prank(alice);
        assertTrue(erc6909.transferFrom(alice, bob, tokenId, 1));
        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
    }

    function testTransferFromCallerIsOperator() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        assertFalse(erc6909.isOperator(alice, bob));
        vm.prank(alice);
        erc6909.setOperator(bob, true);

        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(bob, alice, bob, tokenId, 1);

        vm.prank(bob);
        assertTrue(erc6909.transferFrom(alice, bob, tokenId, 1));
        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
        assertTrue(erc6909.isOperator(alice, bob));
    }

    function testApprove() public {
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Approval(alice, bob, tokenId, 1);

        vm.prank(alice);
        erc6909.approve(bob, tokenId, 1);

        assertEq(erc6909.allowance(alice, bob, tokenId), 1);
    }

    function testSetOperator() public {
        assertFalse(erc6909.isOperator(alice, bob));
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit OperatorSet(alice, bob, true);

        vm.prank(alice);
        erc6909.setOperator(bob, true);

        assertTrue(erc6909.isOperator(alice, bob));
    }

    function testSupportsInterface() public {
        // type(Ierc6909).interfaceId
        // type(IERC165).interfaceId
        assertTrue(erc6909.supportsInterface(0xb2e69f8a));
        assertTrue(erc6909.supportsInterface(0x01ffc9a7));
    }

    function testTransferZeroValue() public {
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(alice, alice, bob, tokenId, 0);

        vm.prank(alice);
        assertTrue(erc6909.transfer(bob, tokenId, 0));
        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
    }

    function testTransferFromZeroValue() public {
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(bob, alice, bob, tokenId, 0);

        vm.prank(bob);
        assertTrue(erc6909.transferFrom(alice, bob, tokenId, 0));
        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
    }

    function testApproveZeroValue() public {
        vm.prank(alice);
        erc6909.approve(bob, tokenId, 1);
        assertEq(erc6909.allowance(alice, bob, tokenId), 1);

        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Approval(alice, bob, tokenId, 0);

        vm.prank(alice);
        erc6909.approve(bob, tokenId, 0);

        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
    }

    function testSetOperatorFalse() public {
        vm.prank(alice);
        erc6909.setOperator(bob, true);
        assertTrue(erc6909.isOperator(alice, bob));

        vm.expectEmit(true, true, true, true, address(erc6909));
        emit OperatorSet(alice, bob, false);

        vm.prank(alice);
        erc6909.setOperator(bob, false);

        assertFalse(erc6909.isOperator(alice, bob));
    }

    function testOperatorDoesNotDeductAllowance() public {
        erc6909.mint(alice, tokenId, 1);
        vm.prank(alice);
        erc6909.approve(bob, tokenId, 1);
        assertEq(erc6909.allowance(alice, bob, tokenId), 1);
        vm.prank(alice);
        erc6909.setOperator(bob, true);
        assertTrue(erc6909.isOperator(alice, bob));

        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(bob, alice, bob, tokenId, 1);

        vm.prank(bob);
        assertTrue(erc6909.transferFrom(alice, bob, tokenId, 1));
        assertEq(erc6909.allowance(alice, bob, tokenId), 1);
        assertEq(erc6909.balanceOf(alice, tokenId), 0);
        assertEq(erc6909.balanceOf(bob, tokenId), 1);
    }

    function testSelfTransfer() public {
        erc6909.mint(alice, tokenId, 1);

        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(alice, alice, alice, tokenId, 1);

        vm.prank(alice);
        assertTrue(erc6909.transfer(alice, tokenId, 1));

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
    }

    function testSelfTransferFrom() public {
        erc6909.mint(alice, tokenId, 1);

        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(alice, alice, alice, tokenId, 1);

        vm.prank(alice);
        assertTrue(erc6909.transferFrom(alice, alice, tokenId, 1));
        assertEq(erc6909.balanceOf(alice, tokenId), 1);
    }

    function testSelfApprove() public {
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Approval(alice, alice, tokenId, 1);

        vm.prank(alice);
        erc6909.approve(alice, tokenId, 1);

        assertEq(erc6909.allowance(alice, alice, tokenId), 1);
    }

    function testSelfSetOperator() public {
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit OperatorSet(alice, alice, true);

        vm.prank(alice);
        erc6909.setOperator(alice, true);

        assertTrue(erc6909.isOperator(alice, alice));
    }

    // ---------------------------------------------------------------------------------------------
    // Failure Cases

    function testTransferInsufficientBalance() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        vm.expectRevert(InsufficientBalance.selector);

        vm.prank(alice);
        erc6909.transfer(bob, tokenId, 2);
    }

    function testTransferFromInsufficientBalance() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        vm.expectRevert(InsufficientBalance.selector);

        vm.prank(alice);
        erc6909.transferFrom(alice, bob, tokenId, 2);
    }

    function testTransferFromInsufficientPermission() public {
        erc6909.mint(alice, tokenId, 1);

        assertEq(erc6909.balanceOf(alice, tokenId), 1);
        assertEq(erc6909.balanceOf(bob, tokenId), 0);
        assertEq(erc6909.allowance(alice, bob, tokenId), 0);
        vm.expectRevert(InsufficientPermission.selector);

        vm.prank(bob);
        erc6909.transferFrom(alice, bob, tokenId, 1);
    }

    // ---------------------------------------------------------------------------------------------
    // Fuzz Tests

    function testFuzzTotalSupply(uint256 id, uint256 value) public {
        erc6909.mint(alice, id, value);

        assertEq(erc6909.totalSupply(id), value);
    }

    function testFuzzBalanceOf(address owner, uint256 id, uint256 value) public {
        erc6909.mint(owner, id, value);

        assertEq(erc6909.balanceOf(owner, id), value);
    }

    function testFuzzAllowance(address owner, address spender, uint256 id, uint256 value) public {
        assertEq(erc6909.allowance(owner, spender, id), 0);
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Approval(owner, spender, id, value);

        vm.prank(owner);
        erc6909.approve(spender, id, value);

        assertEq(erc6909.allowance(owner, spender, id), value);
    }

    function testFuzzTransfer(address sender, address receiver, uint256 id, uint256 value) public {
        erc6909.mint(sender, id, value);

        if (sender != receiver) {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), 0);
        } else {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), value);
        }
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(sender, sender, receiver, id, value);

        vm.prank(sender);
        assertTrue(erc6909.transfer(receiver, id, value));

        if (sender != receiver) {
            assertEq(erc6909.balanceOf(sender, id), 0);
            assertEq(erc6909.balanceOf(receiver, id), value);
        } else {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), value);
        }
    }

    function testFuzzTransferFrom(address spender, address sender, address receiver, uint256 id, uint256 value)
        public
    {
        erc6909.mint(sender, id, value);

        if (sender != receiver) {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), 0);
        } else {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), value);
        }
        assertEq(erc6909.allowance(sender, spender, id), 0);
        vm.prank(sender);
        erc6909.approve(spender, id, value);
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(spender, sender, receiver, id, value);

        vm.prank(spender);
        assertTrue(erc6909.transferFrom(sender, receiver, id, value));

        if (sender != receiver) {
            assertEq(erc6909.balanceOf(sender, id), 0);
            assertEq(erc6909.balanceOf(receiver, id), value);
        } else {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), value);
        }
        if (sender != spender && value != type(uint256).max) {
            assertEq(erc6909.allowance(sender, spender, id), 0);
        } else {
            assertEq(erc6909.allowance(sender, spender, id), value);
        }
    }

    function testFuzzTransferFromCallerIsSender(address sender, address receiver, uint256 id, uint256 value) public {
        erc6909.mint(sender, id, value);

        if (sender != receiver) {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), 0);
        } else {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), value);
        }
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(sender, sender, receiver, id, value);

        vm.prank(sender);
        assertTrue(erc6909.transferFrom(sender, receiver, id, value));

        if (sender != receiver) {
            assertEq(erc6909.balanceOf(sender, id), 0);
            assertEq(erc6909.balanceOf(receiver, id), value);
        } else {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), value);
        }
    }

    function testFuzzTransferFromCallerIsOperator(
        address spender,
        address sender,
        address receiver,
        uint256 id,
        uint256 value
    ) public {
        erc6909.mint(sender, id, value);

        if (sender != receiver) {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), 0);
        } else {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), value);
        }
        assertFalse(erc6909.isOperator(sender, spender));
        vm.prank(sender);
        erc6909.setOperator(spender, true);
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(spender, sender, receiver, id, value);

        vm.prank(spender);
        assertTrue(erc6909.transferFrom(sender, receiver, id, value));

        if (sender != receiver) {
            assertEq(erc6909.balanceOf(sender, id), 0);
            assertEq(erc6909.balanceOf(receiver, id), value);
        } else {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), value);
        }
        assertTrue(erc6909.isOperator(sender, spender));
    }

    function testFuzzApprove(address owner, address spender, uint256 id, uint256 value) public {
        assertEq(erc6909.allowance(owner, spender, id), 0);
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Approval(owner, spender, id, value);

        vm.prank(owner);
        erc6909.approve(spender, id, value);

        assertEq(erc6909.allowance(owner, spender, id), value);
    }

    function testFuzzSetOperator(address owner, address spender, bool approved) public {
        assertFalse(erc6909.isOperator(owner, spender));
        vm.expectEmit(true, true, true, true, address(erc6909));
        emit OperatorSet(owner, spender, approved);

        vm.prank(owner);
        erc6909.setOperator(spender, approved);

        assertEq(erc6909.isOperator(owner, spender), approved);
    }

    function testFuzzOperatorDoesNotDeductAllowance(
        address spender,
        address sender,
        address receiver,
        uint256 id,
        uint256 value
    ) public {
        erc6909.mint(sender, id, value);
        vm.prank(sender);
        erc6909.approve(spender, id, value);
        assertEq(erc6909.allowance(sender, spender, id), value);

        vm.prank(sender);
        erc6909.setOperator(spender, true);
        assertTrue(erc6909.isOperator(sender, spender));

        vm.expectEmit(true, true, true, true, address(erc6909));
        emit Transfer(spender, sender, receiver, id, value);

        vm.prank(spender);
        assertTrue(erc6909.transferFrom(sender, receiver, id, value));
        assertEq(erc6909.allowance(sender, spender, id), value);

        if (sender != receiver) {
            assertEq(erc6909.balanceOf(sender, id), 0);
            assertEq(erc6909.balanceOf(receiver, id), value);
        } else {
            assertEq(erc6909.balanceOf(sender, id), value);
            assertEq(erc6909.balanceOf(receiver, id), value);
        }
    }

    function testFuzzTransferInsufficientBalance(address sender, address receiver, uint256 id, uint256 value) public {
        value = bound(value, 1, type(uint256).max);
        assertEq(erc6909.balanceOf(sender, id), 0);
        assertEq(erc6909.balanceOf(receiver, id), 0);
        vm.expectRevert(InsufficientBalance.selector);

        vm.prank(sender);
        erc6909.transfer(receiver, id, value);
    }

    function testFuzzTransferFromInsufficientBalance(address sender, address receiver, uint256 id, uint256 value)
        public
    {
        value = bound(value, 1, type(uint256).max);
        assertEq(erc6909.balanceOf(sender, id), 0);
        assertEq(erc6909.balanceOf(receiver, id), 0);
        vm.expectRevert(InsufficientBalance.selector);

        vm.prank(sender);
        erc6909.transferFrom(sender, receiver, id, value);
    }

    function testFuzzTransferFromInsufficientPermission(
        address spender,
        address sender,
        address receiver,
        uint256 id,
        uint256 value
    ) public {
        vm.assume(spender != sender);
        value = bound(value, 1, type(uint256).max);
        assertEq(erc6909.balanceOf(sender, id), 0);
        assertEq(erc6909.balanceOf(receiver, id), 0);
        assertEq(erc6909.allowance(sender, spender, id), 0);
        vm.expectRevert(InsufficientPermission.selector);

        vm.prank(spender);
        erc6909.transferFrom(sender, receiver, id, value);
    }
}
