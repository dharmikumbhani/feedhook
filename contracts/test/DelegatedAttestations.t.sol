// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

// Imports
import "../src/AttestationStationMiddleware.sol";
import "forge-std/Test.sol";
import "../src/AttestationStation/AttestationStation.sol";
import "../src/SchemaRegistry.sol";
import {DelegatedSchemaAttestationRequest, Signature} from '../src/ISchemaRegistry.sol';
import {SigUtils, AttestationData as atstData} from "./SigUtils.sol";
contract DelegatedTest is Test {
    uint256 bobKey = 128;
    uint256 aliceKey = 256;
    uint256 delegateKey = 512;
    address bob = vm.addr(bobKey);
    address alice = vm.addr(aliceKey);
    address delegateAddr = vm.addr(delegateKey);

    string name = "Attestation Station Middleware";
    string version = "0.0.1";

    AttestationStation atst;
    AttestationStationMiddleware attestationStationMiddleware;
    SchemaRegistry schemaRegistry;
    SigUtils sigUtils;

    event SubmittedDelegatedSchemaAttestation(address indexed about, bytes32 indexed key, address indexed delegate, bytes data, address attester);

    function setUp() public {
        // Label Bob and Alice
        vm.label(bob, "bob");
        vm.label(alice, "alice");
        vm.label(delegateAddr, "delegate");
        // Give Ether to Bob and Alice
        vm.deal(bob, 1 ether);
        vm.deal(alice, 1 ether);
        vm.deal(delegateAddr, 1 ether);

        // Deploy AttestationStation
        atst = new AttestationStation();
        // Deploy SchemaRegistry
        schemaRegistry = new SchemaRegistry(address(atst));

        // Deploy AttestationVerifier
        attestationStationMiddleware = new AttestationStationMiddleware(address(atst), schemaRegistry);
        sigUtils = new SigUtils(attestationStationMiddleware.getDomainSeparator());
    }

    // Test getDomainSeparator: Return Value
    // Command: forge test --match-test test_getDomainSeparator
    function test_getDomainSeparator() public {
        bytes32 domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            block.chainid,
            address(attestationStationMiddleware)
        ));
        assertEq(attestationStationMiddleware.getDomainSeparator(), domainSeparator);
    } 


    // Test getAttestationTypeHash: Return Value
    // Command: forge test --match-test test_getAttestationTypeHash
    function test_getAttestationTypeHash() public {
        bytes32 typeHash = keccak256("Attestation(address about,bytes32 key,bytes value,address delegate,uint256 nonce)");
        assertEq(attestationStationMiddleware.getAttestationTypeHash(), typeHash);
    }

    // Test getNonce: Return Value
    // Command: forge test --match-test test_getNonce
    function test_getNonce() public {
        assertEq(attestationStationMiddleware.getNonce(bob), 0);
    }

    // Test verifyAttestation: Return Value
    // Command: forge test --match-test test_verifyAttestation
    function test_verifyAttestation() public {
        // Register a schema
        string memory schema = "{text: string, number: uint256}";
        address resolver = alice;
        bool revocable = true;
        SchemaRecord memory data = SchemaRecord({
            uid: bytes32(0),
            schema: schema,
            resolver: resolver,
            revocable: revocable,
            delegatable: true,
            delegate: delegateAddr
        });

        bytes32 schemaUid = schemaRegistry.registerSchema(data);

        // Sign the message with bob's private key
        uint256 nonce = attestationStationMiddleware.getNonce(bob);
        
        atstData memory digestData = atstData({
            about: alice,
            key: bytes32("key"),
            val: "{text: Hello World!, number: 123}", // Follows Schema Format
            delegate: delegateAddr
        });
        // Digest
        bytes32 digest = sigUtils.getTypedDataHash(digestData, nonce);

        // Sign
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKey, digest);

        Signature memory signature = Signature({
            v: v,
            r: r,
            s: s
        });

        // Attestation Request
        DelegatedSchemaAttestationRequest memory request = DelegatedSchemaAttestationRequest({
            uid: schemaUid,
            about: alice,
            key: bytes32("key"),
            data: "{text: Hello World!, number: 123}", // Follows Schema Format
            delegate: delegateAddr,
            signature: signature,
            attester: bob
        });

        // Make sure the signed value bytes are the same as the data bytes in the request
        assertEq(request.data, digestData.val);

        // Verify Attestation
        assertEq(attestationStationMiddleware.verifyAttestation(request), true);
    }

    // Test submitDelegatedSchemaAttestation: Emit
    // Command: forge test --match-test test_submitDelegatedSchemaAttestation
    // function test_submitDelegatedSchemaAttestation() public {
    //     // Register a schema
    //     string memory schema = "{text: string, number: uint256}";
    //     address resolver = alice;
    //     bool revocable = true;
    //     SchemaRecord memory data = SchemaRecord({
    //         uid: bytes32(0),
    //         schema: schema,
    //         resolver: resolver,
    //         revocable: revocable,
    //         delegatable: true,
    //         delegate: delegateAddr
    //     });
    //     bytes32 schemaUid = schemaRegistry.registerSchema(data);
    //     // Sign the message with bob's private key
    //     uint256 nonce = attestationStationMiddleware.getNonce(bob);
        
    //     // Digest
    //     bytes32 digest = sigUtils.getTypedDataHash(atstData({
    //         about: alice,
    //         key: bytes32("key"),
    //         val: "{text: Hello World!, number: 123}", // Follows Schema Format
    //         delegate: delegateAddr
    //     }), nonce);
    //     // Sign 
    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKey, digest);

    //     Signature memory signature = Signature({
    //         v: v,
    //         r: r,
    //         s: s
    //     });


    //     // Delegated Attestation Request
    //     DelegatedSchemaAttestationRequest memory request = DelegatedSchemaAttestationRequest({
    //         uid: schemaUid,
    //         about: alice,
    //         key: bytes32("key"),
    //         data: bytes("Hello World!"),
    //         delegate: delegateAddr,
    //         attester: bob, // Now bob has to sign the message to approve the delegate.
    //         signature: signature
    //     });

    //     // Submit the attestation
    //     vm.prank(delegateAddr); // Called by delegate else it'll fail
    //     vm.expectEmit(true, true, true, true, address(attestationStationMiddleware));
    //     emit SubmittedDelegatedSchemaAttestation(request.about, request.key, request.delegate, request.data, request.attester);
    //     attestationStationMiddleware.submitDelegatedSchemaAttestation(request);
    // }
}
