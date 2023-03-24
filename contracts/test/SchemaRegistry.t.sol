pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/SchemaRegistry.sol";
import {ISchemaRegistry, SchemaRecord} from "../src/ISchemaRegistry.sol";

contract SchemaRegistryTest is Test {
    SchemaRegistry public schemaRegistry;
    address bob = address(128);
    address alice = address(256);

    // Events
    event SchemaRegistered(bytes32 indexed uid, address indexed registerer, address resolver, bool revocable, string schema);
    
    function setUp() public {
        schemaRegistry = new SchemaRegistry();
        vm.deal(bob, 1 ether);
        vm.deal(alice, 1 ether);
        vm.label(bob, "bob");
        vm.label(alice, "alice");
    }

    // Test registerSchema: Event Emit and Return Value
    function test_registerSchema() public {
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable
        });
        bytes32 uid = keccak256(abi.encodePacked(data.schema, data.resolver, data.revocable));
        vm.expectEmit(true, true, true, true, address(schemaRegistry));
        emit SchemaRegistered(uid, bob, data.resolver, data.revocable, data.schema);
        vm.prank(bob);
        bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
        assertEq(schemaUid, uid);
    }

    // Test getSchema: Return Value
    function test_getSchema() public {
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable
        });
        bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
        assertEq(schemaRegistry.getSchema(schemaUid).uid, schemaUid);
        assertEq(schemaRegistry.getSchema(schemaUid).schema, schema);
        assertEq(schemaRegistry.getSchema(schemaUid).resolver, resolver);
        assertEq(schemaRegistry.getSchema(schemaUid).revocable, revocable);
    }

    // Test_Fail registerSchema: SchemaAlreadyRegistered
    function testFail_registerSchema_SchemaAlreadyRegistered() public {
        // Register Schema First Time
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable
        });
        bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);

        // Try registering the same schema again
        vm.expectRevert("SchemaAlreadyRegistered");
        schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
    }

    // Test_Fail getSchema: SchemaNotFound
    function testFail_getSchema_SchemaNotFound() public {
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable
        });
        bytes32 uid = keccak256(abi.encodePacked(data.schema, data.resolver, data.revocable));
        // Did not register the schema
        vm.expectRevert("SchemaNotFound");
        schemaRegistry.getSchema(bytes32(uid));
    }
}