<!--
parent:
  order: false
-->

<div align="center">
  <h1> Nami Chain </h1>
</div>

Nami Chain is a scalable, high-throughput Proof-of-Stake EVM blockchain
that is fully compatible and interoperable with Ethereum.
It's built using the [Cosmos SDK](https://github.com/cosmos/cosmos-sdk/)
which runs on top of the [CometBFT](https://github.com/cometbft/cometbft) consensus engine.

## Quick Start

To learn how Nami Chain works from a high-level perspective,
go to the [Protocol Overview](https://docs.evmos.org/protocol) section of the documentation.
You can also check the instructions to [Run a Node](https://docs.evmos.org/protocol/evmos-cli#run-an-evmos-node).

## Documentation

Our documentation is hosted in a [separate repository](https://github.com/evmos/docs) and can be found at [docs.evmos.org](https://docs.evmos.org).
Head over there and check it out.

## Installation

For prerequisites and detailed build instructions
please read the [Installation](https://docs.evmos.org/protocol/evmos-cli) instructions.
Once the dependencies are installed, run:

```bash
make install
```

Or check out the latest [release](https://github.com/tungns-nami/nami-chain/releases).

## Contributing

Looking for a good place to start contributing?
Check out some
[`good first issues`](https://github.com/tungns-nami/nami-chain/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22).

For additional instructions, standards and style guides, please refer to the [Contributing](./CONTRIBUTING.md) document.

## Licensing

Starting from April 21st, 2023, the Nami Chain repository will update its License
from GNU Lesser General Public License v3.0 (LGPLv3) to [Evmos Non-Commercial
License 1.0 (ENCL-1.0)](./LICENSE). This license applies to all software released from Nami Chain
version 13 or later, except for specific files, as follows, which will continue
to be licensed under LGPLv3:

- `x/erc20/keeper/proposals.go`
- `x/erc20/types/utils.go`

LGPLv3 will continue to apply to older versions ([<v13.0.0](https://github.com/tungns-nami/nami-chain/releases/tag/v12.1.5))
of the Nami Chain repository. For more information see [LICENSE](./LICENSE).

> [!WARNING]
>
> **NOTE: If you are interested in using this software**
> email us at [os@evmos.org](mailto:os@evmos.org).

### SPDX Identifier

The following header including a license identifier in [SPDX](https://spdx.dev/learn/handling-license-info/)
short form has been added to all ENCL-1.0 files:

```go
// Copyright Tharsis Labs Ltd.(Nami Chain)
// SPDX-License-Identifier:ENCL-1.0(https://github.com/tungns-nami/nami-chain/blob/main/LICENSE)
```

Exempted files contain the following SPDX ID:

```go
// Copyright Tharsis Labs Ltd.(Nami Chain)
// SPDX-License-Identifier:LGPL-3.0-only
```

### License FAQ

Find below an overview of the Permissions and Limitations of the Evmos Non-Commercial License 1.0.
For more information, check out the full ENCL-1.0 FAQ [here](./LICENSE_FAQ.md).

| Permissions                                                                                                                                                                  | Prohibited                                                                 |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| - Private Use, including distribution and modification<br />- Commercial use on designated blockchains<br />- Commercial use with Nami Chain permit (to be separately negotiated) | - Commercial use, other than on designated blockchains, without Nami Chain permit |
