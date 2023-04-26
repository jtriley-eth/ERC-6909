# @version 0.3.7

# @title ERC6909 Multi-Token
# @author jtriley.eth
# TODO: tests

# @notice The event emitted when a transfer occurs.
# @param sender The address of the sender.
# @param receiver The address of the receiver.
# @param id The id of the token.
# @param amount The amount of the token.
event Transfer:
    sender: indexed(address)
    recipient: indexed(address)
    id: indexed(uint256)
    amount: uint256

# @notice The event emitted when an operator is set.
# @param owner The address of the owner.
# @param spender The address of the spender.
# @param approved The approval status.
event OperatorSet:
    owner: indexed(address)
    spender: indexed(address)
    approved: bool

# @notice The event emitted when an approval occurs.
# @param owner The address of the owner.
# @param spender The address of the spender.
# @param id The id of the token.
# @param amount The amount of the token.
event Approval:
    owner: indexed(address)
    spender: indexed(address)
    id: indexed(uint256)
    amount: uint256

# @notice The total supply of each id.
# @param id The id of the token.
# @return amount The total supply of the token.
totalSupply: public(HashMap[uint256, uint256])


# @notice Owner balance of an id.
# @param owner The address of the owner.
# @param id The id of the token.
# @return amount The balance of the token.
balanceOf: public(HashMap[address, HashMap[uint256, uint256]])


# @notice Spender allowance of an id.
# @param owner The address of the owner.
# @param spender The address of the spender.
# @param id The id of the token.
# @return amount The allowance of the token.
allowance: public(HashMap[address, HashMap[address, HashMap[uint256, uint256]]])


# @notice Checks if a spender is approved by an owner as an operator
# @param owner The address of the owner.
# @param spender The address of the spender.
# @return approved The approval status.
isOperator: public(HashMap[address, HashMap[address, bool]])


# @notice Transfers an amount of an id from the caller to a receiver.
# @param receiver The address of the receiver.
# @param id The id of the token.
# @param amount The amount of the token.
@external
def transfer(receiver: address, id: uint256, amount: uint256):
    assert self.balanceOf[msg.sender][id] >= amount, "insufficient balance"
    self.balanceOf[msg.sender][id] -= amount
    self.balanceOf[receiver][id] += amount
    log Transfer(msg.sender, receiver, id, amount)


# @notice Transfers an amount of an id from a sender to a receiver.
# @param sender The address of the sender.
# @param receiver The address of the receiver.
# @param id The id of the token.
# @param amount The amount of the token.
@external
def transferFrom(sender: address, receiver: address, id: uint256, amount: uint256):
    if sender != msg.sender or not self.isOperator[sender][msg.sender]:
        assert self.allowance[sender][msg.sender][id] >= amount, "insufficient allowance"
        self.allowance[sender][msg.sender][id] -= amount
    assert self.balanceOf[sender][id] >= amount, "insufficient balance"
    self.balanceOf[sender][id] -= amount
    self.balanceOf[receiver][id] += amount
    log Transfer(sender, receiver, id, amount)


# @notice Approves an amount of an id to a spender.
# @param spender The address of the spender.
# @param id The id of the token.
# @param amount The amount of the token.
@external
def approve(spender: address, id: uint256, amount: uint256):
    self.allowance[msg.sender][spender][id] = amount
    log Approval(msg.sender, spender, id, amount)


# @notice Sets or removes a spender as an operator for the caller.
# @param spender The address of the spender.
# @param approved The approval status.
@external
def setOperator(spender: address, approved: bool):
    self.isOperator[msg.sender][spender] = approved
    log OperatorSet(msg.sender, spender, approved)


# @notice Checks if a contract implements an interface.
# @param interfaceId The interface identifier, as specified in ERC-165.
# @return supported True if the contract implements `interfaceId` and
# `interfaceId` is not 0xffffffff, false otherwise.
@external
@pure
def supportsInterface(interfaceID: bytes4) -> bool:
    return interfaceID in [0x01ffc9a7, 0x8da179e8]
