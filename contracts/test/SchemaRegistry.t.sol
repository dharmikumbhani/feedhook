pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/SchemaRegistry.sol";
import {ISchemaRegistry, SchemaRecord} from "../src/ISchemaRegistry.sol";

contract SchemaRegistryTest is Test {
    SchemaRegistry public schemaRegistry;

    // Events
    event SchemaRegistered(bytes32 indexed uid, address registrar);
    
    function setUp() public {
        schemaRegistry = new SchemaRegistry();
    }

    function test_registerSchema() public {
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: "Test Schema",
            resolver: address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431),
            revocable: true
        });
        bytes32 uid = keccak256(abi.encodePacked(data.schema, data.resolver, data.revocable));
        vm.expectEmit(true, true, false, true, address(schemaRegistry));
        emit SchemaRegistered(uid, address(0));
        bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
        assertEq(schemaUid, uid);
    }

    function test_getSchema() public {
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: "Test Schema",
            resolver: address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431),
            revocable: true
        });
        bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
        assertEq(schemaRegistry.getSchema(schemaUid).schema, "Test Schema");
        assertEq(schemaRegistry.getSchema(schemaUid).resolver, address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431));
        assertEq(schemaRegistry.getSchema(schemaUid).revocable, true);
    }

    function testFail_registerSchemaRevert() public {
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: "Test Schema",
            resolver: address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431),
            revocable: true
        });
        bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);

        // Try registering the same schema again
        vm.expectRevert("SchemaAlreadyRegistere");
        schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
    }
}