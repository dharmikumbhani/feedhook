// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import {ISchemaRegistry, SchemaRecord} from "./ISchemaRegistry.sol";

struct RegisterDappData {
    address registerer; // Address of the person who is registering the DApp
    address dapp; // Address of the DApp - this will be the about address in the attestation
    string name; // Name of the DApp
}

/*
* @dev AttestationData taken OP AttestationStation contract.
*/
struct AttestationData {
    address about; // Address of the DApp - this will be the about address in the attestation
    bytes32 key; // Key of the attestation
    bytes value; // Value of the attestation
}

/*
* @dev Interface of the Feedhook contract.
*/

interface IFeedhook {
    /*
     * @dev Emitted when a DApp registers themselves with the Feedhook contract.
     */
    event Registered(address indexed dapp, string name, address indexed registar);

    /*
     * @dev Emitted when a DApp unregisters themselves with the Feedhook contract.
     */
    event Unregistered(address indexed dapp);

    /*
     * @dev Emitted when a DApp updates their registered address and name.
     */
    event Updated(address indexed dapp, string name);

    /*
     * @dev Emitted when an attestation is submitted to the AttestationStation contract.
     */

    event AttestationSubmitted(address indexed creator, address indexed about, bytes32 indexed key, bytes value);

    /*
     * @dev Returns the address of the SchemaRegistry contract.
     * @return The address of the SchemaRegistry contract.
     */

    function getSchemaRegistry() external view returns (ISchemaRegistry);

    /*
     * @dev Registers a DApp with the Feedhook contract.
     * @param RegisterDappData The data required to register a DApp. See RegisterDappData struct.
     */

    function registerDapp(RegisterDappData calldata _data) external;

}