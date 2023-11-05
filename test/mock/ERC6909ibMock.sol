// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/ERC6909ib.sol";

contract ERC6909ibMock is ERC6909ib {
    mapping(uint256 tokenId => uint256 assets) public assets;

    constructor(ERC20 _asset, string memory _name, string memory _symbol) ERC6909ib(_name, _symbol, _asset) {}

    function totalAssets(uint256 tokenId) public view override returns (uint256) {
        return assets[tokenId];
    }

    function beforeWithdraw(uint256 tokenId, uint256 amount, uint256) internal override {
        assets[tokenId] -= amount;
    }

    function afterDeposit(uint256 tokenId, uint256 amount, uint256) internal override {
        assets[tokenId] += amount;
    }
}
