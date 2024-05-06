// based on https://github.com/tornadocash/tornado-core/blob/master/contracts/Tornado.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./MerkleTreeWithHistory.sol";

interface IVerifier {
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[3] memory input
    ) external pure returns (bool r);
}

contract ZKTree is MerkleTreeWithHistory {
    mapping(bytes32 => uint256) public nullifierHashes;
    mapping(bytes32 => bool) public saltedNullifierHashes;
    mapping(bytes32 => bool) public commitments;

    IVerifier public immutable verifier;
    uint256 private immutable i_nullifierUseCount;

    event Commit(
        bytes32 indexed commitment,
        uint32 leafIndex,
        uint256 timestamp
    );

    constructor(
        uint32 _levels,
        IHasher _hasher,
        IVerifier _verifier,
        uint256 nullifierUseCount

    ) MerkleTreeWithHistory(_levels, _hasher) {
        verifier = _verifier;
        i_nullifierUseCount = nullifierUseCount;
    }

    function _commit(bytes32 _commitment) internal {
        require(!commitments[_commitment], "The commitment has been submitted");

        commitments[_commitment] = true;
        uint32 insertedIndex = _insert(_commitment);
        emit Commit(_commitment, insertedIndex, block.timestamp);
    }

    function _nullify(
        bytes32 _nullifierHash,
        bytes32 _root,
        bytes32 _saltedNullifierHash,
        uint[2] memory _proof_a,
        uint[2][2] memory _proof_b,
        uint[2] memory _proof_c
    ) internal {
        require(nullifierHashes[_nullifierHash] < i_nullifierUseCount, "The nullifier has been used too many times");
        require(!saltedNullifierHashes[_saltedNullifierHash], "The salted nullifier has been used");
        require(isKnownRoot(_root), "Cannot find your merkle root");
        require(
            verifier.verifyProof(
                _proof_a,
                _proof_b,
                _proof_c,
                [uint256(_nullifierHash), uint256(_root), uint256(_saltedNullifierHash)]
            ),
            "Invalid proof"
        );

        nullifierHashes[_nullifierHash] += 1;   
        saltedNullifierHashes[_saltedNullifierHash] = true; 
    }
}
