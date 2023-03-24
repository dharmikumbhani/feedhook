// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {ISchemaRegistry, SchemaRecord} from "./ISchemaRegistry.sol";
import "forge-std/console.sol";
// Errors
error SchemaAlreadyRegistered();
error SchemaNotRegistered();
contract SchemaRegistry is ISchemaRegistry {
    // State
    mapping(bytes32 => SchemaRecord) private schemaRegistry;

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
}