# zk-merkle-tree

This package is a fork of [zk-merkle-tree](https://github.com/TheBojda/zk-merkle-tree) with support for using one nullifier multiple times.


The library is based on the source code of [Tornado Cash](https://github.com/tornadocash/tornado-core). The most essential component of TC is a Merkle tree where users can deposit ethers with a random `commitment`, that can be withdrawn with a `nullifier`. The nullifier is assigned to the commitment, but nobody knows which commitment is assigned to which nullifier, because the link between them is the zero-knowledge. This method can be also used for anonymous voting, where the voter sends a commitment in the registration phase, and a nullifier when she votes. This method ensures that one voter can vote only once. 

For more info, please read [Laszlo Fazekas's article on Medium about the original library](https://thebojda.medium.com/an-introduction-of-zk-merkle-tree-a-javascript-library-for-anonymous-voting-on-ethereum-using-79caa3415d1e).

## Usage

When constructing `ZKTree`, use `nullifierUseCount` to limit the number of times a nullifier can be used. Check [Original repository](https://github.com/TheBojda/zk-merkle-tree) for details.