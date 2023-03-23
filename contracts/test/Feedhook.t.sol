// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "../src/Feedhook.sol";
import "../src/SchemaRegistry.sol";
import "../src/AttestationStation/AttestationStation.sol";



contract FeedhookTest is Test {
    struct AttestationData {
        address about;
        bytes32 key;
        bytes value;
        bytes32 schemaUid;
    }
    Feedhook public feedhook;
    ISchemaRegistry public schemaRegistry;
    address bob = address(128);
    address alice = address(256);
    event AttestationSubmitted(address indexed creator, address indexed about, bytes32 indexed key, bytes value);
    AttestationStation attestationStation;
    
    function setUp() public {
        // Label Bob and Alice
        vm.label(bob, "bob");
        vm.label(alice, "alice");
        // Give Ether to Bob and Alice
        vm.deal(bob, 1 ether);
        vm.deal(alice, 1 ether);

        // Deploy Attestation Station
        attestationStation = new AttestationStation();

        // Deploy Contracts
        schemaRegistry = new SchemaRegistry();
        feedhook = new Feedhook(schemaRegistry, address(attestationStation));
    }

    // Test registerDapp: Event Emit
    event Registered(address indexed dapp, string name, address indexed registar);
    function test_registerDapp() public {
        RegisterDappData memory data = RegisterDappData({
            dapp: address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431),
            name: "Test Dapp",
            registerer: address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431)
        });
        vm.expectEmit(true, true, true, true, address(feedhook));
        emit Registered(address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431), "Test Dapp", address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431));
        feedhook.registerDapp(data);
    }

    // Test getRegisteredDapp: Return Value
    function test_getRegisteredDapp() public {
        RegisterDappData memory data = RegisterDappData({
            dapp: address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431),
            name: "Test Dapp",
            registerer: address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431)
        });
        feedhook.registerDapp(data);
        assertEq(feedhook.getRegisteredDapp(address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431)).dapp, address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431));
        assertEq(feedhook.getRegisteredDapp(address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431)).name, "Test Dapp");
        assertEq(feedhook.getRegisteredDapp(address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431)).registerer, address(0x798e39A31d8a49729C0057B4059A4Dc19e00C431));
    }
}