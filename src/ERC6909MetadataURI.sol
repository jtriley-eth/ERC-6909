// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ERC6909Metadata.sol";
import "./interfaces/IERC6909MetadataURI.sol";

contract ERC6909MetadataURI is ERC6909Metadata, IERC6909MetadataURI {
    /// @dev Thrown when the id does not exist.
    /// @param id The id of the token.
    error InvalidId(uint256 id);

    /// @notice The URI for each id.
    /// @return The URI of the token.
    function tokenURI(uint256) public pure override returns (string memory) {
        return "<baseuri>/{id}";
    }
}
