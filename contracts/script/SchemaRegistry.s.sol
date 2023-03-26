// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {SchemaRegistry} from "../src/SchemaRegistry.sol";
import "forge-std/Script.sol";

contract SchemaRegistryScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address ATST = 0xEE36eaaD94d1Cc1d0eccaDb55C38bFfB6Be06C77;
        SchemaRegistry schemaRegistry = new SchemaRegistry(ATST);
        vm.stopBroadcast();
    }
}