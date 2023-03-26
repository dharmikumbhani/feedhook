/**
 * @title AttestationVerifier
 * @dev Contract for verifying off-chain attestations
 */

pragma solidity 0.8.15;

// Imports
import "openzeppelin/utils/cryptography/EIP712.sol";
import "openzeppelin/utils/cryptography/ECDSA.sol";
import "forge-std/console.sol";
import {DelegatedSchemaAttestationRequest} from "./ISchemaRegistry.sol";
// Errors
error InvalidSignature();
struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

abstract contract AttestationVerifier is EIP712 {
    // keccak256("Attestation(address about,bytes32 key,bytes value,address delegate,uint256 nonce)")
    bytes32 private constant ATTESTATION_TYPEHASH = 0x2812820e950af8bd419c6b4c2562dab02e487099f15fa02ca847d16c1a9af11f;
    
    // Replay protection
    mapping(address => uint256) private _nonces;
    

    constructor(string memory name, string memory version) EIP712(name, version) {}

    function getDomainSeparator() public view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function getAttestationTypeHash() public pure returns (bytes32) {
        return ATTESTATION_TYPEHASH;
    }

    function getNonce(address _attester) public view returns (uint256) {
        return _nonces[_attester];
    }


    /**
     * @dev internal verification function for verifying signed off-chain attestations
     * @param _attestation The attestation to verify
     * @dev _attestation.delegate should be same as the delegate in the schemaRecord and also the same while signing the message else signature will be invalid.
     */
    function _verifyAttestation(
        DelegatedSchemaAttestationRequest memory _attestation) internal returns (address) {
            address _attester = _attestation.attester; 
            // Check the nonce
            uint256 nonce;
            unchecked {
                nonce = _nonces[_attester]++;
            }

            // Verify the signature
            bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
                ATTESTATION_TYPEHASH,
                _attestation.about,
                _attestation.key,
                _attestation.data, // value in attestation
                _attestation.delegate,
                nonce
            )));

            address signer = ECDSA.recover(digest, _attestation.signature.v, _attestation.signature.r, _attestation.signature.s);

            if (signer != _attester) {
                revert InvalidSignature();
            }

            return _attester;
        }
}