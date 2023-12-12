// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IERC6909TokenSupply.sol";
import "./ERC6909.sol";

/// @title ERC6909 Token Supply Extension
/// @author jtriley.eth
/// @notice Extends the ERC6909 interface with a total supply tracker for each token.
contract ERC6909TokenSupply is ERC6909, IERC6909TokenSupply {
    /// @notice Total supply of a token.
    mapping(uint256 id => uint256) public totalSupply;
}
