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
struct AttestationData {
    address about;
    bytes32 key;
    bytes val;
}
struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct OffChainAttestationRequest {
    AttestationData attestationData;
    Signature signature;
    address attester;
}

contract AttestationVerifier is EIP712 {
    // keccak256("Attestation(address about,bytes32 key,bytes value)")
    bytes32 private constant ATTESTATION_TYPEHASH = keccak256("Attestation(address about,bytes32 key,bytes value,uint256 nonce)");
    
    // Replay protection
    mapping(address => uint256) private _nonces;
    
    address public immutable ATTESTATION_STATION;

    constructor(string memory name, string memory version, address _atst) EIP712(name, version) {
        ATTESTATION_STATION = _atst;
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

    function verifyAttestation(
        AttestationData calldata _attestation,
        Signature calldata _signature,
        address _attester
    ) external returns (address) {
        return _verifyAttestation(_attestation, _signature, _attester);
    }

    /**
     * @dev private verification function
     * @param _attestation The attestation to verify
     * @param _signature The signature of the attestation
     * @param _attester The address of the attester
     */
    function _verifyAttestation(
        AttestationData calldata _attestation,
        Signature calldata _signature,
        address _attester) private returns (address) {
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
                _attestation.val,
                nonce
            )));

            address signer = ECDSA.recover(digest, _signature.v, _signature.r, _signature.s);

            if (signer != _attester) {
                revert InvalidSignature();
            }

            return _attester;

        }

    /**
     * @dev Submit off-chain attestations on-chain (WIP)
     * @param _requests The requests to submit
     */
    
    function _submitAttestations(OffChainAttestationRequest[] calldata _requests) external {
        for (uint256 i = 0; i < _requests.length; i++) {
            OffChainAttestationRequest calldata request = _requests[i];
            _verifyAttestation(request.attestationData, request.signature, request.attester);

            // Delegated Attestation Call to Attestation Station as attester will not be the msg.sender
            // Create Schema DelegatedAttestationCall. How to create a universal schema for this? Such all schema can be submitted by a delegate.
            // Add boolean delegate
            // Add address delegateAddr
            // Can schema creator change delegate address?
        }
    }
}