// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {ERC6909ibMock} from "./mock/ERC6909ibMock.sol";

contract ERC4626Test is Test {
    MockERC20 underlying;
    ERC6909ibMock vault;

    function setUp() public {
        underlying = new MockERC20("Mock Token", "TKN", 18);
        vault = new ERC6909ibMock(underlying, "Mock Token Vault", "vwTKN");
    }

    function invariantMetadata() public {
        assertEq(vault.name(), "Mock Token Vault");
        assertEq(vault.symbol(), "vwTKN");
        assertEq(vault.decimals(), 18);
    }

    function testMetadata(string calldata name, string calldata symbol) public {
        ERC6909ibMock vlt = new ERC6909ibMock(underlying, name, symbol);
        assertEq(vlt.name(), name);
        assertEq(vlt.symbol(), symbol);
        assertEq(address(vlt.asset()), address(underlying));
    }

    function testSingleDepositWithdraw(uint128 amount) public {
        if (amount == 0) amount = 1;

        uint256 aliceUnderlyingAmount = amount;

        address alice = address(0xABCD);

        underlying.mint(alice, aliceUnderlyingAmount);

        vm.prank(alice);
        underlying.approve(address(vault), aliceUnderlyingAmount);
        assertEq(underlying.allowance(alice, address(vault)), aliceUnderlyingAmount);

        uint256 alicePreDepositBal = underlying.balanceOf(alice);

        vm.prank(alice);
        uint256 tokenId = 1;
        uint256 aliceShareAmount = vault.deposit(tokenId, aliceUnderlyingAmount, alice);

        // Expect exchange rate to be 1:1 on initial deposit.
        assertEq(aliceUnderlyingAmount, aliceShareAmount);
        assertEq(vault.previewWithdraw(tokenId, aliceShareAmount), aliceUnderlyingAmount);
        assertEq(vault.previewDeposit(tokenId, aliceUnderlyingAmount), aliceShareAmount);
        assertEq(vault.totalSupply(tokenId), aliceShareAmount);
        assertEq(vault.totalAssets(tokenId), aliceUnderlyingAmount);
        assertEq(vault.balanceOf(alice, tokenId), aliceShareAmount);
        assertEq(vault.convertToAssets(tokenId, vault.balanceOf(alice, tokenId)), aliceUnderlyingAmount);
        assertEq(underlying.balanceOf(alice), alicePreDepositBal - aliceUnderlyingAmount);

        vm.prank(alice);
        vault.withdraw(tokenId, aliceUnderlyingAmount, alice, alice);

        assertEq(vault.totalAssets(tokenId), 0);
        assertEq(vault.balanceOf(alice, tokenId), 0);
        assertEq(vault.convertToAssets(tokenId, vault.balanceOf(alice, tokenId)), 0);
        assertEq(underlying.balanceOf(alice), alicePreDepositBal);
    }

    function testSingleMintRedeem(uint128 amount) public {
        if (amount == 0) amount = 1;
        uint256 tokenId = 1;
        uint256 aliceShareAmount = amount;

        address alice = address(0xABCD);

        underlying.mint(alice, aliceShareAmount);

        vm.prank(alice);
        underlying.approve(address(vault), aliceShareAmount);
        assertEq(underlying.allowance(alice, address(vault)), aliceShareAmount);

        uint256 alicePreDepositBal = underlying.balanceOf(alice);

        vm.prank(alice);
        uint256 aliceUnderlyingAmount = vault.mint(tokenId, aliceShareAmount, alice);

        // Expect exchange rate to be 1:1 on initial mint.
        assertEq(aliceShareAmount, aliceUnderlyingAmount);
        assertEq(vault.previewWithdraw(tokenId, aliceShareAmount), aliceUnderlyingAmount);
        assertEq(vault.previewDeposit(tokenId, aliceUnderlyingAmount), aliceShareAmount);
        assertEq(vault.totalSupply(tokenId), aliceShareAmount);
        assertEq(vault.totalAssets(tokenId), aliceUnderlyingAmount);
        assertEq(vault.balanceOf(alice, tokenId), aliceUnderlyingAmount);
        assertEq(vault.convertToAssets(tokenId, vault.balanceOf(alice, tokenId)), aliceUnderlyingAmount);
        assertEq(underlying.balanceOf(alice), alicePreDepositBal - aliceUnderlyingAmount);

        vm.prank(alice);
        vault.redeem(tokenId, aliceShareAmount, alice, alice);

        assertEq(vault.totalAssets(0), 0);
        assertEq(vault.balanceOf(alice, tokenId), 0);
        assertEq(vault.convertToAssets(tokenId, vault.balanceOf(alice, tokenId)), 0);
        assertEq(underlying.balanceOf(alice), alicePreDepositBal);
    }

    function testFailDepositWithNotEnoughApproval() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);
        assertEq(underlying.allowance(address(this), address(vault)), 0.5e18);

        vault.deposit(0, 1e18, address(this));
    }

    function testFailWithdrawWithNotEnoughUnderlyingAmount() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(0, 0.5e18, address(this));

        vault.withdraw(0, 1e18, address(this), address(this));
    }

    function testFailRedeemWithNotEnoughShareAmount() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(0, 0.5e18, address(this));

        vault.redeem(0, 1e18, address(this), address(this));
    }

    function testFailWithdrawWithNoUnderlyingAmount() public {
        vault.withdraw(0, 1e18, address(this), address(this));
    }

    function testFailRedeemWithNoShareAmount() public {
        vault.redeem(0, 1e18, address(this), address(this));
    }

    function testFailDepositWithNoApproval() public {
        vault.deposit(0, 1e18, address(this));
    }

    function testFailMintWithNoApproval() public {
        vault.mint(0, 1e18, address(this));
    }

    function testFailDepositZero() public {
        vault.deposit(0, 0, address(this));
    }

    function testMintZero() public {
        vault.mint(0, 0, address(this));

        assertEq(vault.balanceOf(address(this), 0), 0);
        assertEq(vault.convertToAssets(0, vault.balanceOf(address(this), 0)), 0);
        assertEq(vault.totalSupply(0), 0);
        assertEq(vault.totalAssets(0), 0);
    }

    function testFailRedeemZero() public {
        vault.redeem(0, 0, address(this), address(this));
    }

    function testWithdrawZero() public {
        vault.withdraw(0, 0, address(this), address(this));

        assertEq(vault.balanceOf(address(this), 0), 0);
        assertEq(vault.convertToAssets(0, vault.balanceOf(address(this), 0)), 0);
        assertEq(vault.totalSupply(0), 0);
        assertEq(vault.totalAssets(0), 0);
    }

    function testVaultInteractionsForSomeoneElse() public {
        uint256 tokenId = 1;
        // init 2 users with a 1e18 balance
        address alice = address(0xABCD);
        address bob = address(0xDCBA);
        underlying.mint(alice, 1e18);
        underlying.mint(bob, 1e18);

        vm.prank(alice);
        underlying.approve(address(vault), 1e18);

        vm.prank(bob);
        underlying.approve(address(vault), 1e18);

        // alice deposits 1e18 for bob
        vm.prank(alice);
        vault.deposit(tokenId, 1e18, bob);

        assertEq(vault.balanceOf(alice, tokenId), 0);
        assertEq(vault.balanceOf(bob, tokenId), 1e18);
        assertEq(underlying.balanceOf(alice), 0);

        // bob mint 1e18 for alice
        vm.prank(bob);
        vault.mint(tokenId, 1e18, alice);
        assertEq(vault.balanceOf(alice, tokenId), 1e18);
        assertEq(vault.balanceOf(bob, tokenId), 1e18);
        assertEq(underlying.balanceOf(bob), 0);

        // alice redeem 1e18 for bob
        vm.prank(alice);
        vault.redeem(tokenId, 1e18, bob, alice);

        assertEq(vault.balanceOf(alice, tokenId), 0);
        assertEq(vault.balanceOf(bob, tokenId), 1e18);
        assertEq(underlying.balanceOf(bob), 1e18);

        // bob withdraw 1e18 for alice
        vm.prank(bob);
        vault.withdraw(tokenId, 1e18, alice, bob);

        assertEq(vault.balanceOf(alice, tokenId), 0);
        assertEq(vault.balanceOf(bob, tokenId), 0);
        assertEq(underlying.balanceOf(alice), 1e18);
    }
}
