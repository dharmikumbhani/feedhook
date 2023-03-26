/**
 * @title AttestationStationMiddleware
 */

pragma solidity 0.8.15;

// Imports
import "forge-std/Test.sol";
import "../src/AttestationStationMiddleware.sol";
import "../src/AttestationStation/AttestationStation.sol";
import "../src/SchemaRegistry.sol";
import {SchemaAttestationRequest} from "../src/ISchemaRegistry.sol";
contract AttestationStationMiddlewareTest is Test {

    // bob and alice
    uint256 bobKey = 128;
    uint256 aliceKey = 256;
    address bob = vm.addr(bobKey);
    address alice = vm.addr(aliceKey);

    // Variables
    AttestationStation attestationStation;
    SchemaRegistry schemaRegistry;
    AttestationStationMiddleware attestationStationMiddleware;

    // Events
    event SchemaAttestationSubmitted(bytes32 schemaUID, address indexed about, bytes32 indexed key, bytes data, address indexed attester);
    event AttestationSubmitted(address indexed about, bytes32 indexed key, bytes val);
    function setUp() public {
        // Deploy AttestaionStation
        attestationStation = new AttestationStation();
        // Deploy SchemaRegistry
        schemaRegistry = new SchemaRegistry(address(attestationStation));

        // Deploy AttestationStationMiddleware
        attestationStationMiddleware = new AttestationStationMiddleware(address(attestationStation), schemaRegistry);
    }

    // Test submitSchemaAttestation: Event Emit
    // Command: forge test --match-test test_submitSchemaAttestation
    function test_submitSchemaAttestation() public {
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
        // SchemaAttestationRequest
        SchemaAttestationRequest memory request = SchemaAttestationRequest({
            uid: schemaUid,
            about: alice,
            key: bytes32("key"),
            data: bytes("Hello World!")
        });
        vm.prank(bob);
        vm.expectEmit(true, true, true, true, address(attestationStationMiddleware));
        emit SchemaAttestationSubmitted(schemaUid, request.about, request.key, request.data, bob);
        attestationStationMiddleware.submitSchemaAttestation(request);
    }

    // Test submitMultipleSchemaAttestations: Event Emit
    // Command: forge test --match-test test_submitMultipleSchemaAttestations
    function test_submitMultipleSchemaAttestations() public {
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

        SchemaAttestationRequest[] memory requests = new SchemaAttestationRequest[](1);
        for(uint160 i = 0; i < 1; i++) {
            requests[i] = SchemaAttestationRequest({
                uid: schemaUid,
                about: alice,
                key: "key",
                data: "hello world"
            });
        }
        vm.prank(bob);
        vm.expectEmit(true, true, true, true, address(attestationStationMiddleware));
        emit SchemaAttestationSubmitted(schemaUid, requests[0].about, requests[0].key, requests[0].data, bob);
        attestationStationMiddleware.submitMultipleSchemaAttestations(requests);
    }

    // Test getAttestations: Return value
    // Command: forge test --match-test test_getAttestations
    function test_getAttestations() public {
        address[] memory attesters = new address[](10);
        bytes[] memory attestations = new bytes[](10);
        AttestationRequestData[] memory requests = new AttestationRequestData[](10);

        // Create multiple attestations
        for(uint256 i = 0; i < 10; i++) {
            // Generate attester
            bytes32 _hash = keccak256(abi.encodePacked(block.timestamp + i));
            address attester = address(uint160(uint256(_hash)));
            attesters[i] = attester;
            // Create attestation
            AttestationData memory attestation = AttestationData({
                about: address(200),
                key: bytes32("test"),
                val: "{text: 'test', number 1}"
            });
            vm.prank(attester);
            // Submit attestation delegatecall
            vm.expectEmit(true, true, true, true, address(attestationStationMiddleware));
            emit AttestationSubmitted(attestation.about, attestation.key, attestation.val);
            attestationStationMiddleware.submitAttestation(attestation);
        }

        // Get attestations
        for(uint256 i = 0; i < 10; i++) {
            requests[i] = AttestationRequestData({
                about: address(200),
                key: bytes32("test"),
                attester: attesters[i]
            });
        }

        attestations = attestationStationMiddleware.getAttestations(requests);

        for(uint256 i = 0; i < 10; i++) {
            assertEq(attestations[i], bytes("{text: 'test', number 1}"));
        }
    }

    // Test getSchemaAttestation: Return value
    // Command: forge test --match-test test_getSchemaAttestation
    function test_getSchemaAttestation() public {
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
        // SchemaAttestationRequest
        SchemaAttestationRequest memory request = SchemaAttestationRequest({
            uid: schemaUid,
            about: alice,
            key: bytes32("key"),
            data: bytes("Hello World!")
        });
        vm.prank(bob);
        vm.expectEmit(true, true, true, true, address(attestationStationMiddleware));
        emit SchemaAttestationSubmitted(schemaUid, request.about, request.key, request.data, bob);
        attestationStationMiddleware.submitSchemaAttestation(request);

        AttestationRequestData memory atstRequest = AttestationRequestData({
            about: alice,
            key: bytes32("key"),
            attester: bob
        });
        SchemaAttestationData memory attestation = attestationStationMiddleware.getSchemaAttestation(atstRequest);
        assertEq(attestation.data, bytes("Hello World!"));
        assertEq(attestation.uid, schemaUid);
        assertEq(attestation.about, alice);
        assertEq(attestation.key, bytes32("key"));
        // Convert bytes to string
        string memory str = string(attestation.data);
        assertEq(str, "Hello World!");

    }

    // Test getMultipleSchemaAttestations: Return value
    // Command: forge test --match-test test_getMultipleSchemaAttestations
    function test_getMultipleSchemaAttestations() public {
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

        address[] memory attesters = new address[](10);
        // Create multiple attestations
        for(uint256 i = 0; i < 10; i++) {
            // Generate attester
            bytes32 _hash = keccak256(abi.encodePacked(block.timestamp + i));
            address attester = address(uint160(uint256(_hash)));
            // Create attestation
            SchemaAttestationRequest memory request = SchemaAttestationRequest({
                uid: schemaUid,
                about: alice,
                key: bytes32("key"),
                data: bytes("Hello World!")
            });
            attesters[i] = attester;
            vm.prank(attester);
            // Submit attestation delegatecall
            vm.expectEmit(true, true, true, true, address(attestationStationMiddleware));
            emit SchemaAttestationSubmitted(schemaUid, request.about, request.key, request.data, attester);
            attestationStationMiddleware.submitSchemaAttestation(request);
        }

        // Get attestations
        AttestationRequestData[] memory requests = new AttestationRequestData[](10);
        for(uint256 i = 0; i < 10; i++) {
            requests[i] = AttestationRequestData({
                about: alice,
                key: bytes32("key"),
                attester: attesters[i]
            });
        }

        bytes[] memory responses = attestationStationMiddleware.getMultipleSchemaAttestations(requests);

        for(uint256 i = 0; i < 1; i++) {
            (bytes32 schemaUID, bytes memory val, address attester) = abi.decode(responses[i], (bytes32, bytes, address));
            assertEq(schemaUID, schemaUid);
            assertEq(val, bytes("Hello World!"));
            assertEq(attester, attesters[i]);
        }
    }

}