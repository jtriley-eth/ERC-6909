# @version 0.3.7

# @title ERCN
# @author jtriley.eth
# TODO: tests

event Transfer:
    sender: indexed(address)
    recipient: indexed(address)
    id: indexed(uint256)
    amount: uint256

event OperatorSet:
    owner: indexed(address)
    spender: indexed(address)
    approved: bool

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    id: indexed(uint256)
    amount: uint256

totalSupply: public(HashMap[uint256, uint256])

balanceOf: public(HashMap[address, HashMap[uint256, uint256]])

allowance: public(HashMap[address, HashMap[address, HashMap[uint256, uint256]]])

isOperator: public(HashMap[address, HashMap[address, bool]])


@external
def transfer(receiver: address, id: uint256, amount: uint256):
    assert self.balanceOf[msg.sender][id] >= amount, "insufficient balance"
    self.balanceOf[msg.sender][id] -= amount
    self.balanceOf[receiver][id] += amount
    log Transfer(msg.sender, receiver, id, amount)


@external
def transferFrom(sender: address, receiver: address, id: uint256, amount: uint256):
    if sender != msg.sender or not self.isOperator[sender][msg.sender]:
        assert self.allowance[sender][msg.sender][id] >= amount, "insufficient allowance"
        self.allowance[sender][msg.sender][id] -= amount
    assert self.balanceOf[sender][id] >= amount, "insufficient balance"
    self.balanceOf[sender][id] -= amount
    self.balanceOf[receiver][id] += amount
    log Transfer(sender, receiver, id, amount)


@external
def approve(spender: address, id: uint256, amount: uint256):
    self.allowance[msg.sender][spender][id] = amount
    log Approval(msg.sender, spender, id, amount)


@external
def setOperator(spender: address, approved: bool):
    self.isOperator[msg.sender][spender] = approved
    log OperatorSet(msg.sender, spender, approved)
