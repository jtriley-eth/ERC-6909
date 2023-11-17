// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC6909} from "./ERC6909.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
// Interest bearing ERC6909

abstract contract ERC6909ib is ERC6909 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(uint256 indexed id, address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        uint256 indexed id,
        address caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The name of the token.
    string public name;

    /// @notice The symbol of the token.
    string public symbol;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Deposits assets for shares.
    /// @param tokenId  The id of the token.
    /// @param assets The amount of assets to deposit.
    /// @param receiver The address of the receiver.
    /// @return shares The amount of shares minted.
    function deposit(uint256 tokenId, uint256 assets, address receiver) public virtual returns (uint256 shares) {
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(tokenId, assets)) != 0, "ZERO_SHARES");
        ERC20 _asset = asset(tokenId);
        // Need to transfer before minting or ERC777s could reenter.
        _asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, tokenId, shares);

        emit Deposit(tokenId, msg.sender, receiver, assets, shares);

        afterDeposit(tokenId, assets, shares);
    }

    /// @dev Mints shares for assets.
    /// @param tokenId The id of the token.
    /// @param shares The amount of shares to mint.
    /// @param receiver The address of the receiver.
    /// @return assets The amount of assets minted.
    function mint(uint256 tokenId, uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(tokenId, shares); // No need to check for rounding error, previewMint rounds up.

        ERC20 _asset = asset(tokenId);

        // Need to transfer before minting or ERC777s could reenter.
        _asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, tokenId, shares);

        emit Deposit(tokenId, msg.sender, receiver, assets, shares);

        afterDeposit(tokenId, assets, shares);
    }

    /// @dev Withdraws assets for shares.
    /// @param tokenId The id of the token.
    /// @param shares The amount of shares to withdraw.
    /// @param receiver The address of the receiver.
    /// @param owner The address of the owner.
    /// @return shares The amount of shares withdrawn.
    function withdraw(uint256 tokenId, uint256 assets, address receiver, address owner)
        public
        virtual
        returns (uint256 shares)
    {
        shares = previewWithdraw(tokenId, assets); // No need to check for rounding error, previewWithdraw rounds up.
        ERC20 _asset = asset(tokenId);
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender][tokenId]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender][tokenId] = allowed - shares;
        }

        beforeWithdraw(tokenId, assets, shares);

        _burn(owner, tokenId, shares);

        emit Withdraw(tokenId, msg.sender, receiver, owner, assets, shares);

        _asset.safeTransfer(receiver, assets);
    }

    /// @dev Redeems shares for assets.
    /// @param tokenId The id of the token.
    /// @param shares The amount of shares to redeem.
    /// @param receiver The address of the receiver.
    /// @param owner The address of the owner.
    /// @return assets The amount of assets redeemed.
    function redeem(uint256 tokenId, uint256 shares, address receiver, address owner)
        public
        virtual
        returns (uint256 assets)
    {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender][tokenId]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender][tokenId] = allowed - shares;
        }
        ERC20 _asset = asset(tokenId);

        // Check for rounding error since we round down in previewRedeem.
        require((assets = previewRedeem(tokenId, shares)) != 0, "ZERO_ASSETS");

        beforeWithdraw(tokenId, assets, shares);

        _burn(owner, tokenId, shares);

        emit Withdraw(tokenId, msg.sender, receiver, owner, assets, shares);

        _asset.safeTransfer(receiver, assets);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/
    /// @dev Returns the total assets of a token.
    /// @param tokenId The id of the token.
    /// @return assets The total assets of the tokenId
    function totalAssets(uint256 tokenId) public view virtual returns (uint256);

    /// @dev Returns the shares of a token for a given amount of assets.
    /// @param tokenId The id of the token.
    /// @param assets The amount of assets.
    /// @return shares The conversion of the assets to shares.
    function convertToShares(uint256 tokenId, uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply[tokenId]; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets(tokenId));
    }

    /// @dev Returns the assets of a token for a given amount of shares.
    /// @param tokenId The id of the token.
    /// @param shares The amount of shares.
    /// @return assets The conversion of the shares to assets.
    function convertToAssets(uint256 tokenId, uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply[tokenId]; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivDown(totalAssets(tokenId), supply);
    }

    /// @dev Preview depositing assets for shares.
    /// @param tokenId The id of the token.
    /// @param assets The amount of shares.
    /// @return shares Preview of the conversion of the assets to shares.
    function previewDeposit(uint256 tokenId, uint256 assets) public view virtual returns (uint256) {
        return convertToShares(tokenId, assets);
    }

    /// @dev Preview minting shares for assets.
    function previewMint(uint256 tokenId, uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply[tokenId]; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(tokenId), supply);
    }

    /// @dev Preview withdrawing shares for assets.
    function previewWithdraw(uint256 tokenId, uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply[tokenId]; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets(tokenId));
    }
    /// @dev Preview redeeming shares for assets.

    function previewRedeem(uint256 tokenId, uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(tokenId, shares);
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/
    /// @dev Returns the maximum amount of assets that can be deposited.
    function maxDeposit(uint256, address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    /// @dev Returns the maximum amount of assets that can be minted.

    function maxMint(uint256, address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    /// @dev Returns the maximum amount of assets that can be withdrawn.

    function maxWithdraw(uint256 tokenId, address owner) public view virtual returns (uint256) {
        return convertToAssets(tokenId, balanceOf[owner][tokenId]);
    }
    /// @dev Returns the maximum amount of shares that can be redeemed.

    function maxRedeem(uint256 tokenId, address owner) public view virtual returns (uint256) {
        return balanceOf[owner][tokenId];
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/
    /// @dev Hook called before withdrawal.
    function beforeWithdraw(uint256 tokenId, uint256 assets, uint256 shares) internal virtual {}
    /// @dev Hook called after deposit. Validate if tokenId is valid here.
    function afterDeposit(uint256 tokenId, uint256 assets, uint256 shares) internal virtual {}

    /*//////////////////////////////////////////////////////////////
                          MINTING AND BURNING
    //////////////////////////////////////////////////////////////*/

    /// @dev Mints shares for an account. Solmate's 6909 already has this.
    /// @param account The address of the account.
    /// @param tokenId The id of the token.
    /// @param shares The amount of shares to mint.
    function _mint(address account, uint256 tokenId, uint256 shares) internal virtual {
        unchecked {
            totalSupply[tokenId] += shares;
        }

        balanceOf[account][tokenId] += shares;
        emit Transfer(msg.sender, address(0), account, tokenId, shares);
    }

    /// @dev Burns shares for an account.
    /// @param account The address of the account.
    /// @param tokenId The id of the token.
    /// @param shares The amount of shares to burn.
    function _burn(address account, uint256 tokenId, uint256 shares) internal virtual {
        unchecked {
            totalSupply[tokenId] -= shares;
        }

        balanceOf[account][tokenId] -= shares;
        emit Transfer(msg.sender, account, address(0), tokenId, shares);
    }

    /*//////////////////////////////////////////////////////////////
                                MISC
    //////////////////////////////////////////////////////////////*/
    function asset(uint256 tokenId) public view virtual returns (ERC20);

    function decimals(uint256 tokenId) public view virtual returns (uint8);
}
