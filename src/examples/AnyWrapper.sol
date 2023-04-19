// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "src/ERC6909.sol";
import "src/examples/interfaces/IERC20Metadata.sol";
import "src/examples/interfaces/IERC721Metadata.sol";
import "src/examples/interfaces/IERC1155Metadata.sol";
import "src/examples/interfaces/IERC1155Receiver.sol";

contract AnyWrapper is ERC6909, IERC1155Receiver {
    error AlreadyRegistered(uint256 localId);
    error NotRegistered(uint256 localId);
    error ERC20TransferFailed(address token, uint256 amount);
    error InsufficientDeposit(uint256 localId, uint256 amount);

    event RegisteredERC20(address indexed token, uint256 indexed localId);
    event RegisteredERC721(address indexed token, uint256 indexed foreignId, uint256 indexed localId);
    event RegisteredERC1155(address indexed token, uint256 indexed foreignId, uint256 indexed localId);

    mapping(uint256 localId => bool registered) public registry;

    function regsiterERC20(address token) public {
        uint256 localId = uint256(uint160(token));
        if (registry[localId]) revert AlreadyRegistered(localId);
        registry[localId] = true;
        decimals[localId] = IERC20Metadata(token).decimals();
        emit RegisteredERC20(token, localId);
    }

    function registerERC721(address token, uint256 foreignId) public {
        uint256 localId = uint256(keccak256(abi.encodePacked(token, foreignId)));
        if (registry[localId]) revert AlreadyRegistered(localId);
        registry[localId] = true;
        emit RegisteredERC721(token, foreignId, localId);
    }

    function registerERC1155(address token, uint256 foreignId) public {
        uint256 localId = uint256(keccak256(abi.encodePacked(token, foreignId)));
        if (registry[localId]) revert AlreadyRegistered(localId);
        registry[localId] = true;
        emit RegisteredERC1155(token, foreignId, localId);
    }

    function wrapERC20(address token, uint256 amount) public {
        uint256 localId = uint256(uint160(token));
        _wrap(msg.sender, localId, amount);
        if (!IERC20Metadata(token).transferFrom(msg.sender, address(this), amount)) {
            revert ERC20TransferFailed(token, amount);
        }
    }

    function wrapERC721(address token, uint256 foreignId) public {
        uint256 localId = uint256(keccak256(abi.encodePacked(token, foreignId)));
        _wrap(msg.sender, localId, 1);
        IERC721Metadata(token).transferFrom(msg.sender, address(this), foreignId);
    }

    function wrapERC1155(address token, uint256 foreignId, uint256 amount) public {
        uint256 localId = uint256(keccak256(abi.encodePacked(token, foreignId)));
        _wrap(msg.sender, localId, amount);
        IERC1155Metadata(token).safeTransferFrom(msg.sender, address(this), foreignId, amount, "");
    }

    function unwrapERC20(address token, uint256 amount) public {
        uint256 localId = uint256(uint160(token));
        _unwrap(msg.sender, localId, amount);
        if (!IERC20Metadata(token).transfer(msg.sender, amount)) {
            revert ERC20TransferFailed(token, amount);
        }
    }

    function unwrapERC721(address token, uint256 foreignId) public {
        uint256 localId = uint256(keccak256(abi.encodePacked(token, foreignId)));
        _unwrap(msg.sender, localId, 1);
        IERC721Metadata(token).transferFrom(address(this), msg.sender, foreignId);
    }

    function uwrapERC1155(address token, uint256 foreignId, uint256 amount) public {
        uint256 localId = uint256(keccak256(abi.encodePacked(token, foreignId)));
        _unwrap(msg.sender, localId, amount);
        IERC1155Metadata(token).safeTransferFrom(address(this), msg.sender, foreignId, amount, "");
    }

    function onERC1155Received(address operator, address from, uint256 foreignId, uint256 amount, bytes calldata)
        public
        returns (bytes4)
    {
        if (operator != address(this)) {
            // the operator is not this contract, so we treat it as a wrap operation by the `from`
            // address.
            uint256 localId = uint256(keccak256(abi.encodePacked(msg.sender, foreignId)));
            _unwrap(from, localId, amount);
        }

        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata foreignIds,
        uint256[] calldata amounts,
        bytes calldata
    ) public returns (bytes4) {
        if (operator != address(this)) {
            // the operator is not this contract, so we treat it as a wrap operation by the `from`
            // address.
            for (uint256 i; i < foreignIds.length; ++i) {
                uint256 localId = uint256(keccak256(abi.encodePacked(msg.sender, foreignIds[i])));
                _wrap(from, localId, amounts[i]);
            }
        }

        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function _wrap(address owner, uint256 localId, uint256 amount) internal {
        if (!registry[localId]) revert NotRegistered(localId);
        balanceOf[owner][localId] += amount;
        totalSupply[localId] += amount;
        emit Transfer(address(0), owner, localId, amount);
    }

    function _unwrap(address owner, uint256 localId, uint256 amount) internal {
        if (!registry[localId]) revert NotRegistered(localId);
        if (balanceOf[owner][localId] < amount) {
            revert InsufficientDeposit(localId, amount);
        }
        balanceOf[owner][localId] -= amount;
        totalSupply[localId] -= amount;
        emit Transfer(owner, address(0), localId, amount);
    }
}
