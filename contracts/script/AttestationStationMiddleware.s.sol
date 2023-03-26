// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {AttestationStationMiddleware} from "../src/AttestationStationMiddleware.sol";
import {ISchemaRegistry} from "../src/ISchemaRegistry.sol";
import "forge-std/Script.sol";

contract AttestationStationMiddlewareScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address ATST = 0xEE36eaaD94d1Cc1d0eccaDb55C38bFfB6Be06C77;
        address schemaRegistry = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
        AttestationStationMiddleware attestationStationMiddleware = new AttestationStationMiddleware(ATST, schemaRegistry);
        vm.stopBroadcast();
    }
}