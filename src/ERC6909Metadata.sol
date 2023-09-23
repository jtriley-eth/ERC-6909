// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ERC6909.sol";
import "./interfaces/IERC6909Metadata.sol";

contract ERC6909Metadata is ERC6909, IERC6909Metadata {
    /// @notice The name of the token.
    string public name = "Example ERC6909 Metadata";

    /// @notice The symbol of the token.
    string public symbol = "EEM";

    /// @notice The number of decimals for each id.
    mapping(uint256 id => uint8 amount) public decimals;
}
