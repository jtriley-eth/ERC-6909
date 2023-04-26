# The "Pretty Obvious If You Think About It" Multi-Token EIP

## Token ID Visualization

```mermaid
flowchart TD
    %% -- ERC6909 --
    user --> id0{Token ID 0}
    id0 --> bn([balanceOf])
    id0 --> an([allowance])
    id0 --> tsn([totalSupply])
    id0 --> dn([decimals])

    user --> idn1{Token ID 1}
    idn1 --> balanceOf1([balanceOf])
    idn1 --> allowance1([allowance])
    idn1 --> total_supply1([totalSupply])
    idn1 --> decimals1([decimals])

    user --> idn2{Token ID n}
    idn2 --> balanceOf([balanceOf])
    idn2 --> allowance([allowance])
    idn2 --> total_supply([totalSupply])
    idn2 --> decimals([decimals])
```

## Links

- [EIP Draft](https://github.com/ethereum/EIPs/pull/6909)
- [EIP Discussion](https://ethereum-magicians.org/t/eip-6909-multi-token-standard/13891)

## Reference Implementations

| Language | Implementation                                          | Status                   |
| -------- | ------------------------------------------------------- | ------------------------ |
| Solidity | [ERC6909](src/ERC6909.sol)                              | complete                 |
| Solidity | [ERC6909Metadata](src/ERC6909Metadata.sol)              | complete                 |
| Solidity | [IERC6909](src/interfaces/IERC6909.sol)                 | complete                 |
| Solidity | [IERC6909Metadata](src/interfaces/IERC6909Metadata.sol) | complete                 |
| Vyper    | [ERC6909](alt/ERC6909.vy)                               | ready for testing        |
| Fe       | [ERC6909](alt/ERC6909.fe)                               | in development (blocked) |
