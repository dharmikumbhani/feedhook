// From: https://book.getfoundry.sh/tutorials/testing-eip712?highlight=sign#diving-in
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import {Attestation} from "../src/AttestationVerifier.sol";
contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    // // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    // bytes32 public constant PERMIT_TYPEHASH =
    //     0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    bytes32 public constant ATTESTATION_TYPEHASH = keccak256("Attestation(address about,bytes32 key,bytes value,uint256 nonce)");

    // computes the hash of a permit
    function getStructHash(Attestation memory _attestation, uint256 _nonce)
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
                    _attestation.value,
                    _nonce
                )
            );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(Attestation memory _attestation, uint256 _nonce)
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