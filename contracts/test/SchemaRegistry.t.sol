pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/SchemaRegistry.sol";
import "../src/AttestationStation/AttestationStation.sol";
import {ISchemaRegistry, SchemaRecord, SchemaAttestation, SchemaAttestation} from "../src/ISchemaRegistry.sol";

contract SchemaRegistryTest is Test {
    SchemaRegistry public schemaRegistry;
    address bob = address(128);
    address alice = address(256);
    // Events
    event SchemaRegistered(bytes32 indexed uid, address indexed registerer, address indexed resolver, bool revocable, string schema);
    event SchemaAttestationSubmitted(bytes32 schemaUID, address indexed about, bytes32 indexed key, bytes data, address indexed attester);
    function setUp() public {
        AttestationStation atst = new AttestationStation();
        schemaRegistry = new SchemaRegistry(address(atst));
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

    // Test submitSchemaAttestation: Return Value
    function test_submitSchemaAttestation() public {
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
        // SchemaAttestation
        SchemaAttestation memory request = SchemaAttestation({
            schemaUID: schemaUid,
            data: "{text: 'test', number 1}",
            about: address(200),
            key: bytes32("test"),
            attester: bob
        });
        vm.prank(bob);
        vm.expectEmit(true, true, true, false, address(schemaRegistry));
        emit SchemaAttestationSubmitted(schemaUid, request.about, request.key, request.data, request.attester);
        schemaRegistry.submitSchemaAttestation(request);
    }

    // Test_Fail submitSchemaAttestation: SchemaNotFound
    // Command: forge test --match-test testFail_submitSchemaAttestation_SchemaNotFound
    function testFail_submitSchemaAttestation_SchemaNotFound() public {
        // SchemaAttestation
        SchemaAttestation memory request = SchemaAttestation({
            schemaUID: bytes32(0),
            data: "{text: 'test', number 1}",
            about: address(200),
            key: bytes32("test"),
            attester: bob
        });
        vm.prank(bob);
        vm.expectRevert("SchemaNotFound");
        schemaRegistry.submitSchemaAttestation(request);
    }

    // Test getSchemaAttetation: Return Value
    // Command: forge test --match-test test_getSchemaAttestation
    function test_getSchemaAttestation() public {
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable
        });
        // Register Schema
        bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
        // SchemaAttestation
        SchemaAttestation memory request = SchemaAttestation({
            schemaUID: schemaUid,
            data: "{text: 'test', number 1}",
            about: address(200),
            key: bytes32("test"),
            attester: bob
        });
        vm.prank(bob);
        // Submit Attestation
        schemaRegistry.submitSchemaAttestation(request);

        // Get Attestation
        SchemaAttestation memory attestation = schemaRegistry.getSchemaAttestation(request.attester, request.about, request.key);
        assertEq(attestation.schemaUID, schemaUid);
        assertEq(attestation.data, request.data);
        assertEq(attestation.about, request.about);
    }

    // Test_Fail getSchemaAttestation: AttestationNotFound
    // Command: forge test --match-test testFail_getSchemaAttestation_AttestationNotFound
    function testFail_getSchemaAttestation_AttestationNotFound() public {
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable
        });
        // Register Schema
        bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
        // SchemaAttestation
        SchemaAttestation memory request = SchemaAttestation({
            schemaUID: schemaUid,
            data: "{text: 'test', number 1}",
            about: address(200),
            key: bytes32("test"),
            attester: bob // bob is the attester
        });
        vm.prank(bob);
        // Submit Attestation
        schemaRegistry.submitSchemaAttestation(request);

        // Get Attestation
        vm.expectRevert("AttestationNotFound");
        // Attempting to get attestation from alice
        schemaRegistry.getSchemaAttestation(alice, request.about, request.key);
    }


}