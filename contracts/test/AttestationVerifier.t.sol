// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
// Imports
import "forge-std/Test.sol";
import {AttestationVerifier, AttestationData, Signature} from "../src/AttestationVerifier.sol";
import "../src/AttestationStation/AttestationStation.sol";
import "./SigUtils.sol";
import "forge-std/console.sol";
contract AttestationVerifierTest is Test {
    // bob and alice
    uint256 bobKey = 128;
    uint256 aliceKey = 256;
    address bob = vm.addr(bobKey);
    address alice = vm.addr(aliceKey);

    string name = "OP_ATST";
    string version = "1";
    AttestationVerifier attestationVerifier;
    AttestationStation atst;
    SigUtils sigUtils;
    function setUp() public {
        // Label Bob and Alice
        vm.label(bob, "bob");
        vm.label(alice, "alice");
        // Give Ether to Bob and Alice
        vm.deal(bob, 1 ether);
        vm.deal(alice, 1 ether);

        // Deploy AttestationVerifier
        atst = new AttestationStation();
        // attestationVerifier = new AttestationVerifier(name, version, address(atst));
        sigUtils = new SigUtils(attestationVerifier.getDomainSeparator());
    }

    // Test getDomainSeparator: Return Value
    // Command: forge test --match-test test_getDomainSeparator
    function test_getDomainSeparator() public {
        bytes32 domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            block.chainid,
            address(attestationVerifier)
        ));
        assertEq(attestationVerifier.getDomainSeparator(), domainSeparator);
    }

    // Test getAttestationTypeHash: Return Value
    // Command: forge test --match-test test_getAttestationTypeHash
    function test_getAttestationTypeHash() public {
        bytes32 attestationTypeHash = keccak256("Attestation(address about,bytes32 key,bytes value,uint256 nonce)");
        assertEq(attestationVerifier.getAttestationTypeHash(), attestationTypeHash);
    }

    // Test getNonce: Return Value
    // Command: forge test --match-test test_getNonce
    function test_getNonce() public {
        assertEq(attestationVerifier.getNonce(bob), 0);
    }

    // Test _verifyAttestation
    // Command: forge test --match-test test_verifyAttestation
    function test_verifyAttestation() public {
        // Attestation
        AttestationData memory attestation = AttestationData({
            about: bob,
            key: keccak256("name"),
            val: "bob"
        });
        
        // get nonce
        uint256 nonce = attestationVerifier.getNonce(bob);

        // bobs private key

        // Sign
        bytes32 digest = sigUtils.getTypedDataHash(attestation, nonce);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKey, digest);

        // Combine v, r, s
        Signature memory signature = Signature({
            v: v,
            r: r,
            s: s
        });
        // Verify
        address attestedBy = attestationVerifier.verifyAttestation(attestation, signature, bob);
        // Check nonce
        assertEq(attestationVerifier.getNonce(bob), 1);
        // Check attestedBy
        assertEq(attestedBy, bob);
    }

}