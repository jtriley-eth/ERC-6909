// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERCN {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id,
        uint256 amount
    );

    event OperatorSet(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id,
        uint256 amount
    );

    function totalSupply(uint256 id) external view returns (uint256 amount);

    function balanceOf(address owner, uint256 id) external view returns (uint256 amount);

    function allowance(
        address owner,
        address spender,
        uint256 id
    ) external view returns (uint256 amount);

    function transfer(address receiver, uint256 id, uint256 amount) external;

    function transferFrom(address sender, address receiver, uint256 id, uint256 amount) external;

    function approve(address spender, uint256 id, uint256 amount) external;

    function setOperator(address operator, bool approved) external;
}