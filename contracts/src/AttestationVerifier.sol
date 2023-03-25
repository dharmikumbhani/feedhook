/**
 * @title AttestationVerifier
 * @dev Contract for verifying off-chain attestations
 */

pragma solidity 0.8.15;

// Imports
import "openzeppelin/utils/cryptography/EIP712.sol";
import "openzeppelin/utils/cryptography/ECDSA.sol";
import "forge-std/console.sol";
// Errors
error InvalidSignature();
struct Attestation {
    address about;
    bytes32 key;
    bytes value;
}
struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

contract AttestationVerifier is EIP712 {
    // keccak256("Attestation(address about,bytes32 key,bytes value)")
    bytes32 private constant ATTESTATION_TYPEHASH = keccak256("Attestation(address about,bytes32 key,bytes value,uint256 nonce)");
    
    // Replay protection
    mapping(address => uint256) private _nonces;

    constructor(string memory name, string memory version) EIP712("OP_ATST", "1") {

    }

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
     * @notice Verifies an attestation
     * @param _attestation The attestation to verify
     * @param _signature The signature of the attestation
     * @param _attester The address of the attester
     */
    // TODO: Convert to internal function
    function _verifyAttestation(
        Attestation calldata _attestation,
        Signature calldata _signature,
        address _attester
    ) external returns (address) {
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
            _attestation.value,
            nonce
        )));

        address signer = ECDSA.recover(digest, _signature.v, _signature.r, _signature.s);

        if (signer != _attester) {
            revert InvalidSignature();
        }

        return _attester;
    }
}