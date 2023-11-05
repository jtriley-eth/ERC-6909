// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface Interface {
    event Approval(address indexed owner, address indexed spender, uint256 indexed id, uint256 amount);
    event Deposit(uint256 indexed id, address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event OperatorSet(address indexed owner, address indexed spender, bool approved);
    event Transfer(
        address caller, address indexed sender, address indexed receiver, uint256 indexed id, uint256 amount
    );
    event Withdraw(
        uint256 indexed id,
        address caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    function allowance(address owner, address spender, uint256 id) external view returns (uint256 amount);
    function approve(address spender, uint256 id, uint256 amount) external returns (bool);
    function asset() external view returns (address);
    function balanceOf(address owner, uint256 id) external view returns (uint256 amount);
    function convertToAssets(uint256 tokenId, uint256 shares) external view returns (uint256);
    function convertToShares(uint256 tokenId, uint256 assets) external view returns (uint256);
    function decimals() external view returns (uint8);
    function deposit(uint256 tokenId, uint256 assets, address receiver) external returns (uint256 shares);
    function isOperator(address owner, address spender) external view returns (bool);
    function maxDeposit(uint256, address) external view returns (uint256);
    function maxMint(uint256, address) external view returns (uint256);
    function maxRedeem(uint256 tokenId, address owner) external view returns (uint256);
    function maxWithdraw(uint256 tokenId, address owner) external view returns (uint256);
    function mint(uint256 tokenId, uint256 shares, address receiver) external returns (uint256 assets);
    function name() external view returns (string memory);
    function previewDeposit(uint256 tokenId, uint256 assets) external view returns (uint256);
    function previewMint(uint256 tokenId, uint256 shares) external view returns (uint256);
    function previewRedeem(uint256 tokenId, uint256 shares) external view returns (uint256);
    function previewWithdraw(uint256 tokenId, uint256 assets) external view returns (uint256);
    function redeem(uint256 tokenId, uint256 shares, address receiver, address owner)
        external
        returns (uint256 assets);
    function setOperator(address spender, bool approved) external returns (bool);
    function supportsInterface(bytes4 interfaceId) external pure returns (bool supported);
    function symbol() external view returns (string memory);
    function totalAssets(uint256 tokenId) external view returns (uint256);
    function totalSupply(uint256 id) external view returns (uint256 amount);
    function transfer(address receiver, uint256 id, uint256 amount) external returns (bool);
    function transferFrom(address sender, address receiver, uint256 id, uint256 amount) external returns (bool);
    function withdraw(uint256 tokenId, uint256 assets, address receiver, address owner)
        external
        returns (uint256 shares);
}
