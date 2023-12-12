// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ERC6909.sol";
import "./interfaces/IERC6909ContentURI.sol";

contract ERC6909ContentURI is ERC6909, IERC6909ContentURI {
    /// @notice The contract level URI.
    string public contractURI;

    /// @notice The URI for each id.
    /// @return The URI of the token.
    function tokenURI(uint256) public pure override returns (string memory) {
        return "<baseuri>/{id}";
    }
}
