pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/SchemaRegistry.sol";
import "../src/AttestationStation/AttestationStation.sol";
import {ISchemaRegistry, SchemaRecord, SchemaAttestation, SchemaAttestation, AttestationRequestData} from "../src/ISchemaRegistry.sol";

contract SchemaRegistryTest is Test {
    SchemaRegistry public schemaRegistry;
    address bob = address(128);
    address alice = address(256);
    AttestationStation atst;
    // Events
    event AttestationSubmitted(address indexed about, bytes32 indexed key, bytes val);
    event SchemaRegistered(bytes32 indexed uid, address indexed registerer, address indexed delegate, bool delegatable, string schema);
    event SchemaAttestationSubmitted(bytes32 schemaUID, address indexed about, bytes32 indexed key, bytes data, address indexed attester);
    function setUp() public {
        atst = new AttestationStation();
        schemaRegistry = new SchemaRegistry(address(atst));
        vm.deal(bob, 1 ether);
        vm.deal(alice, 1 ether);
        vm.label(bob, "bob");
        vm.label(alice, "alice");
    }

    // Test registerSchema: Event Emit and Return Value
    // Command: forge test --match-test test_registerSchema
    function test_registerSchema() public {
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable,
            delegatable: false,
            delegate: address(0)
        });
        bytes32 uid = keccak256(abi.encodePacked(data.schema, data.resolver, data.revocable, data.delegatable, data.delegate));
        vm.expectEmit(true, true, true, true, address(schemaRegistry));
        emit SchemaRegistered(uid, bob, data.delegate, data.delegatable, data.schema);
        vm.prank(bob);
        bytes32 schemaUid = schemaRegistry.registerSchema(data);
        assertEq(schemaUid, uid);
    }

    // Test getSchema: Return Value
    // Command: forge test --match-test test_getSchema
    function test_getSchema() public {
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable,
            delegatable: false,
            delegate: address(0)
        });
        bytes32 schemaUid = schemaRegistry.registerSchema(data);
        assertEq(schemaRegistry.getSchema(schemaUid).uid, schemaUid);
        assertEq(schemaRegistry.getSchema(schemaUid).schema, schema);
        assertEq(schemaRegistry.getSchema(schemaUid).resolver, resolver);
        assertEq(schemaRegistry.getSchema(schemaUid).revocable, revocable);
        assertEq(schemaRegistry.getSchema(schemaUid).delegatable, false);
        assertEq(schemaRegistry.getSchema(schemaUid).delegate, address(0));
    }

    // Test_Fail registerSchema: SchemaAlreadyRegistered
    // Command: forge test --match-test testFail_registerSchema_SchemaAlreadyRegistered
    function testFail_registerSchema_SchemaAlreadyRegistered() public {
        // Register Schema First Time
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable,
            delegatable: false,
            delegate: address(0)
        });
        bytes32 schemaUid = schemaRegistry.registerSchema(data);
        // Try registering the same schema again
        vm.expectRevert("SchemaAlreadyRegistered");
        schemaUid = schemaRegistry.registerSchema(data);
    }

    // Test_Fail getSchema: SchemaNotFound
    // Command: forge test --match-test testFail_getSchema_SchemaNotFound
    function testFail_getSchema_SchemaNotFound() public {
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable,
            delegatable: false,
            delegate: address(0)
        });
        bytes32 uid = keccak256(abi.encodePacked(data.schema, data.resolver, data.revocable, data.delegatable, data.delegate));
        // Did not register the schema
        vm.expectRevert("SchemaNotRegistered");
        schemaRegistry.getSchema(bytes32(uid));
    }

    // TODO: Move to AttestationStationMiddleware
    // Test submitSchemaAttestation_single: Return Value
    // Command: forge test --match-test test_submitSchemaAttestation 
    // function test_submitSchemaAttestation() public {
    //     string memory schema = "{text: string, number: uint256}";
    //     address resolver = alice;
    //     bool revocable = true;
    //     SchemaRecord memory data = SchemaRecord({
    //         uid: bytes32(0),
    //         schema: schema,
    //         resolver: resolver,
    //         revocable: revocable,
    //         delegatable: false,
    //         delegate: address(0),
    //         timestamp: block.timestamp
    //     });
    //     bytes32 schemaUid = schemaRegistry.registerSchema(data);
    //     // SchemaAttestation
    //     SchemaAttestation memory request = SchemaAttestation({
    //         schemaUID: schemaUid,
    //         data: "{text: 'test', number 1}",
    //         about: address(200),
    //         key: bytes32("test"),
    //         attester: bob
    //     });
    //     vm.prank(bob);
    //     vm.expectEmit(true, true, true, false, address(schemaRegistry));
    //     emit SchemaAttestationSubmitted(schemaUid, request.about, request.key, request.data, request.attester);
    //     schemaRegistry.submitSchemaAttestation(request);
    // }

    // // Test submitSchemaAttestation_multiple: Return Value
    // // Command: forge test --match-test test_multiSubmitSchemaAttestation
    // function test_multiSubmitSchemaAttestation() public {
    //     string memory schema = "{text: string, number: uint256}";
    //     address resolver = alice;
    //     bool revocable = true;
    //     SchemaRecord memory data = SchemaRecord({
    //         uid: bytes32(0),
    //         schema: schema,
    //         resolver: resolver,
    //         revocable: revocable
    //     });
    //     // Register Schema
    //     bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);

    //     // Submit multiple attestations
    //     SchemaAttestation[] memory requests = new SchemaAttestation[](10);
    //     for (uint256 i = 0; i < 10; i++) {
    //         // SchemaAttestation
    //         SchemaAttestation memory request = SchemaAttestation({
    //             schemaUID: schemaUid,
    //             data: "{text: 'test', number 1}",
    //             about: address(200),
    //             key: bytes32("test"),
    //             attester: bob
    //         });
    //         requests[i] = request;
    //     }
    //     vm.prank(bob);
    //     vm.expectEmit(true, true, true, false, address(schemaRegistry));
    //     emit SchemaAttestationSubmitted(schemaUid, requests[1].about, requests[1].key, requests[1].data, requests[1].attester);
    //     schemaRegistry.multiSubmitSchemaAttestation(requests);
    // }

    // // Test_Fail submitSchemaAttestation: SchemaNotFound
    // // Command: forge test --match-test testFail_submitSchemaAttestation_SchemaNotFound
    // function testFail_submitSchemaAttestation_SchemaNotFound() public {
    //     // SchemaAttestation
    //     SchemaAttestation memory request = SchemaAttestation({
    //         schemaUID: bytes32(0),
    //         data: "{text: 'test', number 1}",
    //         about: address(200),
    //         key: bytes32("test"),
    //         attester: bob
    //     });
    //     vm.prank(bob);
    //     vm.expectRevert("SchemaNotFound");
    //     schemaRegistry.submitSchemaAttestation(request);
    // }

    // // Test getSchemaAttetation: Return Value
    // // Command: forge test --match-test test_getSchemaAttestation
    // function test_getSchemaAttestation() public {
    //     string memory schema = "{text: string, number: uint256}";
    //     address resolver = alice;
    //     bool revocable = true;
    //     SchemaRecord memory data = SchemaRecord({
    //         uid: bytes32(0),
    //         schema: schema,
    //         resolver: resolver,
    //         revocable: revocable
    //     });
    //     // Register Schema
    //     bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
    //     // SchemaAttestation
    //     SchemaAttestation memory request = SchemaAttestation({
    //         schemaUID: schemaUid,
    //         data: "{text: 'test', number 1}",
    //         about: address(200),
    //         key: bytes32("test"),
    //         attester: bob
    //     });
    //     vm.prank(bob);
    //     // Submit Attestation
    //     schemaRegistry.submitSchemaAttestation(request);

    //     // Get Attestation
    //     SchemaAttestation memory attestation = schemaRegistry.getSchemaAttestation(request.attester, request.about, request.key);
    //     assertEq(attestation.schemaUID, schemaUid);
    //     assertEq(attestation.data, request.data);
    //     assertEq(attestation.about, request.about);
    // }

    // // Test_Fail getSchemaAttestation: AttestationNotFound
    // // Command: forge test --match-test testFail_getSchemaAttestation_AttestationNotFound
    // function testFail_getSchemaAttestation_AttestationNotFound() public {
    //     string memory schema = "{text: string, number: uint256}";
    //     address resolver = alice;
    //     bool revocable = true;
    //     SchemaRecord memory data = SchemaRecord({
    //         uid: bytes32(0),
    //         schema: schema,
    //         resolver: resolver,
    //         revocable: revocable
    //     });
    //     // Register Schema
    //     bytes32 schemaUid = schemaRegistry.registerSchema(data.schema, data.resolver, data.revocable);
    //     // SchemaAttestation
    //     SchemaAttestation memory request = SchemaAttestation({
    //         schemaUID: schemaUid,
    //         data: "{text: 'test', number 1}",
    //         about: address(200),
    //         key: bytes32("test"),
    //         attester: bob // bob is the attester
    //     });
    //     vm.prank(bob);
    //     // Submit Attestation
    //     schemaRegistry.submitSchemaAttestation(request);

    //     // Get Attestation
    //     vm.expectRevert("AttestationNotFound");
    //     // Attempting to get attestation from alice
    //     schemaRegistry.getSchemaAttestation(alice, request.about, request.key);
    // }

    // // Test getMultipleAttestations: Return Value
    // // Command: forge test --match-test test_getMultipleAttestations
    // function test_getMultipleAttestations() public {

    //     address[] memory attesters = new address[](10);
    //     bytes[] memory attestations = new bytes[](10);
    //     AttestationRequestData[] memory requests = new AttestationRequestData[](10);
    //     // Create multiple attestations
    //     for(uint256 i = 0; i < 10; i++) {
    //         // Generate attester
    //         bytes32 _hash = keccak256(abi.encodePacked(block.timestamp + i));
    //         address attester = address(uint160(uint256(_hash)));
    //         attesters[i] = attester;
    //         // Create attestation
    //         AttestationData memory attestation = AttestationData({
    //             about: address(200),
    //             key: bytes32("test"),
    //             val: "{text: 'test', number 1}"
    //         });
    //         vm.prank(attester);
    //         // Submit attestation delegatecall
    //         vm.expectEmit(true, true, true, true, address(schemaRegistry));
    //         emit AttestationSubmitted(attestation.about, attestation.key, attestation.val);
    //         schemaRegistry.submitAttestation(attestation);
    //     }

    //     // Get attestations
    //     for(uint256 i = 0; i < 10; i++) {
    //         requests[i] = AttestationRequestData({
    //             about: address(200),
    //             key: bytes32("test"),
    //             attester: attesters[i]
    //         });
    //     }

    //     attestations = schemaRegistry.getMultipleAttestations(requests);

    //     for(uint256 i = 0; i < 10; i++) {
    //         assertEq(attestations[i], bytes("{text: 'test', number 1}"));
    //     }
        
    // }

}