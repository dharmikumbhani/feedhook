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
}
interface ISchemaRegistry {

    // Events

    /**
     * @dev Emitted when a schema is registered.
     */
     event SchemaRegistered(bytes32 indexed uid, address registerer, address resolver, bool revocable, string schema);
    /**
     * @dev Registers a schema with the registry.
     * @param schema The schema to register.
     * @param revocable Whether the schema allows revocations explicitly.
     * @return uid The unique identifier of the schema.
     */
    function registerSchema(string calldata schema, address resolver, bool revocable) external returns (bytes32 uid);

    /**
     * @notice Revokes a schema from the registry.
     * @param uid The unique identifier of the schema.
     */
    function revokeSchema(bytes32 uid) external;

    /**
     * @notice Gets a schema record from the registry.
     * @param uid The unique identifier of the schema.
     * @return record The schema record.
     */
    function getSchema(bytes32 uid) external view returns (SchemaRecord memory record);
}