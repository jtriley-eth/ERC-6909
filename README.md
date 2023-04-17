# The "Pretty Obvious If You Think About It" Multi-Token Standard

**Requires** [EIP-165](https://eips.ethereum.org/EIPS/eip-165)

## Table of Contents

- [The "Pretty Obvious If You Think About It" Multi-Token Standard](#the-pretty-obvious-if-you-think-about-it-multi-token-standard)
  - [Table of Contents](#table-of-contents)
  - [Abstract](#abstract)
  - [Motivation](#motivation)
  - [Specification](#specification)
    - [Definitions](#definitions)
    - [Methods](#methods)
      - [totalSupply](#totalsupply)
      - [balanceOf](#balanceof)
      - [allowance](#allowance)
      - [transfer](#transfer)
      - [transferFrom](#transferfrom)
      - [approve](#approve)
      - [setOperator](#setoperator)
    - [Events](#events)
      - [Transfer](#transfer-1)
      - [OperatorSet](#operatorset)
      - [Approval](#approval)
  - [Reference Implementation](#reference-implementation)

## Abstract

The following standard specifies a multi-token contract as a simplified alternative to the
[ERC-1155 Standard](https://eips.ethereum.org/EIPS/eip-1155).

## Motivation

The current multi-token standard includes unnecessary featues such as requiring recipient accounts
with code to implement callbacks returning specific values and batch-calls in the specification. In
addition, the single operator permission scheme grants unlimited allowance on every token ID in the
contract.

## Specification

### Definitions

- infinite: the maximum value for a uint256 (`2 ** 256 - 1`).
- caller: the caller of the current context (`msg.sender`).
- spender: an account that transfers tokens on behalf of another account.
- operator: an account that has unlimited transfer permissions on all token ids for another account.

### Methods

#### totalSupply

The total supply for a given token id.

MUST be equal to the total number of units of a token id that exists.

```yaml
- name: totalSupply
  type: function
  stateMutability: view

  inputs:
    - name: id
      type: uint256

  outputs:
    - name: amount
      type: uint256
```

#### balanceOf

The total number of units of a token id that an account owns.

```yaml
- name: balanceOf
  type: function
  stateMutability: view

  inputs:
    - name: owner
      type: address
    - name: id
      type: uint256

  outputs:
    - name: amount
      type: uint256
```

#### allowance

The total number of units of a token id that a spender is premitted to transfer on behalf of an
owner.

```yaml
- name: allowance
  type: function
  stateMutability: view

  inputs:
    - name: owner
      type: address
    - name: spender
      type: address
    - name: id
      type: uint256

  outputs:
    - name: amount
      type: uint256
```

#### transfer

Transfers an amount of units of a token id from the caller to the receiver.

MUST revert when the caller's balance for the token id is insufficient.

MUST log the Transfer event.

SHOULD decrease the caller's balance for the token id by the amount.

SHOULD increase the receiver's balance for the token id by the amount.

```yaml
- name: transfer
  type: function
  stateMutability: nonpayable

  inputs:
    - name: receiver
      type: address
    - name: id
      type: uint256
    - name: amount
      type: uint256

  outputs: []
```

#### transferFrom

Transfers an amount of units of a token id from a sender to a receiver by the caller.

MUST revert when the caller is not an operator for the spender and the caller's allowance for the
token id for the sender is insufficient.

MUST revert when the caller's balance for the token id is insufficient.

MUST log the Transfer event.

MUST decrease the caller's allowance for the sender if the allowance is not infinite.

SHOULD decrease the sender's balance for the token id by the amount.

SHOULD increase the receiver's balance for the token id by the amount.

SHOULD NOT decrease the caller's allowance for the token id for the sender if the allowance is
infinite.

SHOULD NOT decrease the caller's allowance for the token id for the sender if the caller is an
operator.

```yaml
- name: transferFrom
  type: function
  stateMutability: nonpayable

  inputs:
    - name: sender
      type: address
    - name: receiver
      type: address
    - name: id
      type: uint256
    - name: amount
      type: uint256

  outputs: []
```

#### approve

Approves an amount of units of a token id that a spender is permitted to transfer on behalf of the
caller.

MUST set the allowance of the spender of the token id for the caller to the amount.

MUST log the Approval event.

```yaml
- name: approve
  type: function
  stateMutability: nonpayable

  inputs:
    - name: spender
      type: address
    - name: id
      type: uint256
    - name: amount
      type: uint256

  outputs: []
```

#### setOperator

Sets a spender as an operator, granting unlimited transfer permissions for any token id for the
caller.

MUST set the operator status to the approved value.

MUST log the OperatorSet event.

```yaml
- name: setOperator
  type: function
  stateMutability: nonpayable

  inputs:
    - name: spender
      type: address
    - name: approved
      type: bool
```

### Events

#### Transfer

The sender has transferred an amount of a token id to a receiver.

MUST be logged when an amount of a token id is transferred from one account to another.

SHOULD be logged with the sender address as the zero address when an amount of a token id is minted.

SHOULD be logged with the receiver address as the zero address when an amount of a token id is
burned.

```yaml
- name: Transfer
  type: event

  inputs:
    - name: sender
      indexed: true
      type: address
    - name: receiver
      indexed: true
      type: address
    - name: id
      indexed: true
      type: address
    - name: amount
      indexed: false
      type: address
```

#### OperatorSet

The owner has set the approved status to the spender.

MUST be logged when the operator status is set.

MAY be logged when the operator status is set to the same status it was before the current call.

```yaml
- name: OperatorSet
  type: event

  inputs:
    - name: owner
      indexed: true
      type: address
    - name: spender
      indexed: true
      type: address
    - name: approved
      indexed: false
      type: bool
```

#### Approval

The owner has approved a spender to transfer an amount of a token id to be transferred on the
owner's behalf.

MUST be logged when the approval is set by the owner.

MAY be logged when the approval is decreased by the transferFrom function.

```yaml
- name: Approval
  type: event

  inputs:
    - name: owner
      indexed: true
      type: address
    - name: spender
      indexed: true
      type: address
    - name: id
      indexed: true
      type: uint256
    - name: amount
      indexed: false
      type: uint256
```

## Reference Implementation

[Contract Reference Implementation](./src/ERCN.sol)

[Interface Reference Implementation](./src/IERCN.sol)
