// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {ISchemaRegistry, SchemaRecord, SchemaAttestation} from "./ISchemaRegistry.sol";

// Errors
error SchemaAlreadyRegistered();
error SchemaNotRegistered();
error AttestationFailed();
error AttestationRetrievalFailed();
contract SchemaRegistry is ISchemaRegistry {
    // State
    mapping(bytes32 => SchemaRecord) private schemaRegistry;
    address public immutable ATTESTATION_STATION;
    constructor(address _attestationStation) {
        ATTESTATION_STATION = _attestationStation;
    }

    // Functions

    function registerSchema(string calldata schema, address resolver, bool revocable) external returns (bytes32) {
        SchemaRecord memory record = SchemaRecord({
            uid: bytes32(0),
            resolver: resolver,
            revocable: revocable,
            schema: schema
        });

        bytes32 uid = getUID(record);
        if(schemaRegistry[uid].uid != bytes32(0)) {
            revert SchemaAlreadyRegistered();
        }
        record.uid = uid;
        schemaRegistry[uid] = record;

        emit SchemaRegistered(uid, msg.sender, resolver, revocable, schema);

        return uid;
    }

    function getSchema(bytes32 uid) external view returns (SchemaRecord memory record) {
        if(schemaRegistry[uid].uid == bytes32(0)) {
            revert SchemaNotRegistered();
        }
        return schemaRegistry[uid];
    }

    // Taken from the EAS SchemaRegistry.sol
    function getUID(SchemaRecord memory schemaRecord) private pure returns (bytes32 uid) {
        return keccak256(abi.encodePacked(schemaRecord.schema, schemaRecord.resolver, schemaRecord.revocable));
    }

    // submitAttestation
    function submitSchemaAttestation(SchemaAttestation calldata _request) external {
        // Check if the schema is registered
        if(schemaRegistry[_request.schemaUID].uid == bytes32(0)) {
            revert SchemaNotRegistered();
        }
        // Submit the attestation to AttestationStation.sol
        _submitSchemaAttestation(_request);
        emit SchemaAttestationSubmitted(_request.schemaUID, _request.about, _request.key, _request.data, _request.attester);
    }

    function _submitSchemaAttestation(SchemaAttestation memory _request) private {
        bytes memory value = abi.encode(_request.schemaUID, _request.data, _request.attester);
        // Make delegate call to AttestationStation.sol
        (bool success, ) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attest(address,bytes32,bytes)", _request.about, _request.key, value));
        if(!success) {
            revert AttestationFailed();
        }
    }

    // getSchemaAttestation
    function getSchemaAttestation(address _attester, address _about, bytes32 _key) external returns (SchemaAttestation memory) {
        // Get the attestation from AttestationStation.sol
        bytes memory value = _getSchemaAttestation(_attester, _about, _key);
        (bytes32 schemaUID, bytes memory data, address attester) = abi.decode(value, (bytes32, bytes, address));
        return SchemaAttestation({
            schemaUID: schemaUID,
            about: _about,
            key: _key,
            data: data,
            attester: attester
        });
    }

    function _getSchemaAttestation(address _attester, address _about, bytes32 _key) private returns (bytes memory) {
        (bool success, bytes memory value) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attestations(address,address,bytes32)", _attester, _about, _key));
        if(!success) {
            revert AttestationRetrievalFailed();
        }
        return abi.decode(value, (bytes));
    }
}