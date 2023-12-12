// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IERC6909.sol";

/// @title ERC6909 Content URI Interface
/// @author jtriley.eth
interface IERC6909ContentURI is IERC6909 {
    /// @notice Contract level URI
    /// @return uri The contract level URI.
    function contractURI() external view returns (string memory);

    /// @notice Token level URI
    /// @param id The id of the token.
    /// @return uri The token level URI.
    function tokenURI(uint256 id) external view returns (string memory);
}
