// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {ISchemaRegistry, SchemaRecord, SchemaAttestationRequest,SchemaAttestationData, AttestationData, AttestationRequestData} from "./ISchemaRegistry.sol";

// Errors
error SchemaAlreadyRegistered();
error SchemaNotRegistered();
error AttestationFailed();
error AttestationRetrievalFailed();
error SchemaNotDelegatableButDelegateNonZero();
error SchemaDelegatableButDelegateZero();
contract SchemaRegistry is ISchemaRegistry {
    // State
    mapping(bytes32 => SchemaRecord) public schemaRegistry;
    address public immutable ATTESTATION_STATION;
    constructor(address _attestationStation) {
        ATTESTATION_STATION = _attestationStation;
    }

    // Functions

    function registerSchema(SchemaRecord calldata _schemaRecord) external returns (bytes32) {
        SchemaRecord memory record = _schemaRecord;

        bytes32 uid = getUID(record);
        if(schemaRegistry[uid].uid != bytes32(0)) {
            revert SchemaAlreadyRegistered();
        }
        if(record.delegatable == false && record.delegate != address(0)) {
            revert SchemaNotDelegatableButDelegateNonZero();
        }
        /**
         * @dev If the schema is delegatable, then the delegate must be non-zero.
         */
        if(record.delegatable == true && record.delegate == address(0)) {
            revert SchemaDelegatableButDelegateZero();
        }
        record.uid = uid;
        schemaRegistry[uid] = record;

        emit SchemaRegistered(uid, msg.sender, record.delegate, record.delegatable, record.schema);

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
        return keccak256(abi.encodePacked(schemaRecord.schema, schemaRecord.resolver, schemaRecord.revocable, schemaRecord.delegatable, schemaRecord.delegate));
    }
}