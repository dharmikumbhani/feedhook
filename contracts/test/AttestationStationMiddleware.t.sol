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

}