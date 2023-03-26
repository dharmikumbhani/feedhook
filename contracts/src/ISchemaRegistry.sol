// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

/**
 * @title A struct representing a record for a submitted schema. Taken from EAS ISchemaRegistry.sol
 */
struct SchemaRecord {
    bytes32 uid; // The unique identifier of the schema.
    address resolver; // The address of the resolver for the schema.
    bool revocable; // Whether the schema allows revocations explicitly.
    string schema; // Custom specification of the schema (e.g., an ABI).
    bool delegatable;// Whether the schema allows delegation of attestations.
    address delegate; // The address of the delegate for the schema.
}

struct SchemaAttestationRequest {
    bytes32 uid; // The unique identifier of the schema.
    address about; // The address of the subject of the attestation.
    bytes32 key; // The key of the attestation.
    bytes data; // The data of the attestation.
    // msg.sender is the attester
}

/**
 * The attester signs (EIP-712) a message containing the following data:
 * 1. about
 * 2. key
 * 3. val (data)
 * 4. nonce
 * 5. delegate. This delegate is from the schemaRecord.
 */

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}
struct DelegatedSchemaAttestationRequest {
    bytes32 uid; // The unique identifier of the schema.
    address about; // The address of the subject of the attestation.
    bytes32 key; // The key of the attestation.
    bytes data; // The data of the attestation.
    address attester; // The address of the attester.
    address delegate; // The address of the delegate.
    Signature signature; // The signature of the attester.
}



struct AttestationData {
    address about;
    bytes32 key;
    bytes val;
}

struct AttestationRequestData {
    address about;
    bytes32 key;
    address attester;
}
struct SchemaAttestationData {
    bytes32 uid;
    address about;
    bytes32 key;
    bytes data;
    address attester;
}
interface ISchemaRegistry {

    // Events
    // TODO: Remove this, was only needed for testing. Was only used in submitAttestation and test_getMultipleAttestations
    event AttestationSubmitted(address indexed about, bytes32 indexed key, bytes val);
    /**
     * @dev Emitted when a schema is registered.
     */
    event SchemaRegistered(bytes32 indexed uid, address indexed registerer, address indexed delegate, bool delegatable, string schema);
    /**
     * @dev Emitted when a schema attestation is submitted.
     * @notice about, key and attester are indexed to retrieve the attestation[attester][about][key] from AttestationStation.sol
     */
    event SchemaAttestationSubmitted(bytes32 schemaUID, address indexed about, bytes32 indexed key, bytes data, address indexed attester);
    /**
     * @dev Registers a schema with the registry.
     * @param _schemaRecord The schema record.
     */
    function registerSchema(SchemaRecord calldata _schemaRecord) external returns (bytes32 uid);

    /**
     * @notice Gets a schema record from the registry.
     * @param uid The unique identifier of the schema.
     * @return record The schema record.
     */
    function getSchema(bytes32 uid) external view returns (SchemaRecord memory record);
    
    /**
     * @notice Submits a schema attestation to AttestationStation.sol
     * @param _request The schema attestation request.
     */
    function submitSchemaAttestation(SchemaAttestationRequest calldata _request) external;

    /**
     * @notice Gets a attestation from AttestationStation.sol, converts it to a SchemaAttestation struct and returns it.
     * @param _attester The address of the attester.
     * @param _about The address of the subject of the attestation.
     * @param _key The key of the attestation.
     * @return The schema attestation.
     */
    function getSchemaAttestation(address _attester, address _about, bytes32 _key) external returns (SchemaAttestationData memory);
}