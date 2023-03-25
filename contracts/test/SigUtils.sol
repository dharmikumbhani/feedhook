// From: https://book.getfoundry.sh/tutorials/testing-eip712?highlight=sign#diving-in
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

struct AttestationData {
    address about;
    bytes32 key;
    bytes val;
    address delegate;
}
contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    bytes32 public constant ATTESTATION_TYPEHASH = keccak256("Attestation(address about,bytes32 key,bytes value,address delegate,uint256 nonce)");

    // computes the hash of the data
    function getStructHash(AttestationData memory _attestation, uint256 _nonce)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    ATTESTATION_TYPEHASH,
                    _attestation.about,
                    _attestation.key,
                    _attestation.val,
                    _attestation.delegate,
                    _nonce
                )
            );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(AttestationData memory _attestation, uint256 _nonce)
        public
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_attestation, _nonce)
                )
            );
    }
}