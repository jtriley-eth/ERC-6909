// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ERCN {
    error InsufficientBalance(address owner, uint256 id);
    error InsufficientPermission(address spender, uint256 id);

    event Transfer(
        address indexed sender,
        address indexed receiver,
        uint256 indexed id,
        uint256 amount
    );

    event OperatorSet(
        address indexed owner,
        address indexed spender,
        bool approved
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id,
        uint256 amount
    );

    mapping(address owner => mapping(uint256 id => uint256 amount)) public balanceOf;

    mapping(
        address owner => mapping(address spender => mapping(uint256 id => uint256 amount))
    ) public allowance;

    mapping(address owner => mapping(address operator => bool)) public isOperator;

    mapping(uint256 id => uint256 amount) public totalSupply;

    function transfer(address receiver, uint256 id, uint256 amount) public {
        if (balanceOf[msg.sender][id] < amount) revert InsufficientBalance(msg.sender, id);
        balanceOf[msg.sender][id] -= amount;
        balanceOf[receiver][id] += amount;
        emit Transfer(msg.sender, receiver, id, amount);
    }

    function transferFrom(address sender, address receiver, uint256 id, uint256 amount) public {
        if (sender != msg.sender && !isOperator[sender][msg.sender]) {
            if (allowance[sender][msg.sender][id] < amount)
                revert InsufficientPermission(msg.sender, id);
            allowance[sender][msg.sender][id] -= amount;
        }
        if (balanceOf[sender][id] < amount) revert InsufficientBalance(sender, id);
        balanceOf[sender][id] -= amount;
        balanceOf[receiver][id] += amount;
        emit Transfer(sender, receiver, id, amount);
    }

    function approve(address spender, uint256 id, uint256 amount) public {
        allowance[msg.sender][spender][id] = amount;
        emit Approval(msg.sender, spender, id, amount);
    }

    function setOperator(address spender, bool approved) public {
        isOperator[msg.sender][spender] = approved;
        emit OperatorSet(msg.sender, spender, approved);
    }
}
