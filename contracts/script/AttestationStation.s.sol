// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "forge-std/Script.sol";
import {AttestationStation} from '../src/AttestationStation/AttestationStation.sol';

contract ATSTScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        AttestationStation attestationStation = new AttestationStation();
        vm.stopBroadcast();
    }
}