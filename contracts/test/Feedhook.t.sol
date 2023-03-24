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

    // Test getSchemaRegistry: Return Value
    function test_getSchemaRegistry() public {
        assertEq(address(schemaRegistry), address(feedhook.getSchemaRegistry()));
    }

    // Test registerDapp: Event Emit
    event Registered(address indexed dapp, string name, address indexed registar);
    function test_registerDapp() public {
        address dapp = address(512);
        string memory name = "Test Dapp";
        address registerer = bob; // Bob register the dapp.
        vm.expectEmit(true, true, true, true, address(feedhook));
        emit Registered(dapp, name, registerer);
        vm.prank(bob);
        feedhook.registerDapp(dapp, name, registerer);
    }

    // Test_Fail registerDapp: DappAlreadyRegistered
    function testFail_registerDapp_DappAlreadyRegistered() public {
        address dapp = address(512);
        string memory name = "Test Dapp";
        address registerer = bob; // Bob register the dapp.
        vm.prank(bob);
        // Register the dapp once.
        feedhook.registerDapp(dapp, name, registerer);
        // Register the dapp again.
        vm.expectRevert("DappAlreadyRegistered");
        feedhook.registerDapp(dapp, name, registerer);
    }

    // Test_Fail registerDapp: ZeroAddress
    function testFail_registerDapp_ZeroAddress() public {
        address dapp = address(0);
        string memory name = "Test Dapp";
        address registerer = address(0); // Bob register the dapp.
        vm.expectRevert("ZeroAddress");
        feedhook.registerDapp(dapp, name, registerer);
    }

    // Test getRegisteredDapp: Return Value
    function test_getRegisteredDapp() public {
        address dapp = address(512);
        string memory name = "Test Dapp";
        address registerer = bob; // Bob register the dapp.
        vm.prank(bob);
        feedhook.registerDapp(dapp, name, registerer);
        assertEq(feedhook.getRegisteredDapp(dapp).dapp, dapp);
        assertEq(feedhook.getRegisteredDapp(dapp).name, "Test Dapp");
        assertEq(feedhook.getRegisteredDapp(dapp).registerer, bob);
    }

    // Test_Fail getRegisteredDapp: UnregisteredDapp
    function testFail_getRegisteredDapp_UnregisteredDapp() public {
        address dapp = address(512);
        vm.expectRevert("UnregisteredDapp");
        feedhook.getRegisteredDapp(dapp);
    }
}