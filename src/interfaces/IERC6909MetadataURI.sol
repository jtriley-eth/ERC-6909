// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/interfaces/IERC6909Metadata.sol";

interface IERC6909MetadataURI is IERC6909Metadata {
    function tokenURI(uint256 id) external view returns (string memory);
}
