// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IERC6909.sol";

/// @title ERC6909 Token Metadata Interface
/// @author jtriley.eth
/// @notice Contains metadata about individual tokens.
interface IERC6909Metadata is IERC6909 {
    /// @notice Name of a given token.
    /// @param id The id of the token.
    /// @return name The name of the token.
    function name(uint256 id) external view returns (string memory);

    /// @notice Symbol of a given token.
    /// @param id The id of the token.
    /// @return symbol The symbol of the token.
    function symbol(uint256 id) external view returns (string memory);

    /// @notice Decimals of a given token.
    /// @param id The id of the token.
    /// @return decimals The decimals of the token.
    function decimals(uint256 id) external view returns (uint8);
}
