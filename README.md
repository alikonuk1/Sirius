[![npm downloads](https://img.shields.io/npm/dt/@alikonuk/sirius)](https://img.shields.io/npm/dt/@alikonuk/sirius)

# Sirius

**Modern** and **exotic**, **customized** solidity **smart contract** library for wide use cases.

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install alikonuk1/Sirius
```

To install with [**Hardhat**](https://github.com/nomiclabs/hardhat) or [**Truffle**](https://github.com/trufflesuite/truffle):

```sh
npm install @alikonuk1/Sirius
```

## Contracts

```ml
src
├─ tokens
├─ ├─ soulbound
│  │  ├─ ERC20SB — "Soulbound ERC20 implementation"
│  │  ├─ ERC721SB — "Soulbound ERC721 implementation"
│  │  ├─ ERC1155SB — "Soulbound ERC1155 implementation"
│  ├─ ERC721CB — "Condition Bound ERC721 implementation"
│  ├─ ERC721L — "EIP-4907: Lendable ERC721 implementation"
├─ utility
│  ├─ SelfMulticall — "SelfMulticall extension"
```

## Safety

This is **experimental software** and is provided on an "as is" and "as available" basis.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

## Acknowledgements

These contracts were inspired by or directly modified from many sources, primarily:

- [solmate](https://github.com/Rari-Capital/solmate)
- [Chiru Labs](https://github.com/chiru-labs/ERC721A)
- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Exo Digital Labs](https://github.com/exo-digital-labs/ERC721R)
- [The Arbiter](https://github.com/The-Arbiter/Condition-Bound-Tokens)

## Support

If you want to support this project, you can donate to the following addresses:

ETH: 0xd6634f05BC79c19cD7027636F3c7c29E853EB844
