pragma circom 2.0.0;

include "CommitmentHasher.circom";
include "MerkleTreeChecker.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

template Verifier(levels) {
    signal input nullifier;
    signal input secret;
    signal input salt;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal output nullifierHash;
    signal output root;
    signal output saltedNullifierHash;

    component commitmentHasher = CommitmentHasher();
    component merkleTreeChecker = MerkleTreeChecker(levels);

    commitmentHasher.nullifier <== nullifier;
    commitmentHasher.secret <== secret;

    merkleTreeChecker.leaf <== commitmentHasher.commitment;
    for (var i = 0; i < levels; i++) {
        merkleTreeChecker.pathElements[i] <== pathElements[i];
        merkleTreeChecker.pathIndices[i] <== pathIndices[i];
    }

    component saltHasher = MiMCSponge(2, 220, 1);
    saltHasher.ins[0] <== nullifier;
    saltHasher.ins[1] <== salt;
    saltHasher.k <== 0;

    saltedNullifierHash <== saltHasher.outs[0];
    nullifierHash <== commitmentHasher.nullifierHash;
    root <== merkleTreeChecker.root;
}

component main = Verifier(20);