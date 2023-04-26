// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "src/interfaces/IERC6909.sol";

interface IERC6909Metadata is IERC6909 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals(uint256 id) external view returns (uint8);
    function tokenURI(uint256 id) external view returns (string memory);
}
