// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

// Imports
import {IFeedhook, RegisterDappData} from "./IFeedhook.sol";
import {SchemaRecord, ISchemaRegistry} from "./ISchemaRegistry.sol";
import {AttestationStation} from "./AttestationStation/AttestationStation.sol";

// Errors
error Unauthorized();
error DappAlreadyRegistered();
error ZeroAddress();
error UnregisteredDapp();
error InvalidSchema();

contract Feedhook is IFeedhook {
    // State
    ISchemaRegistry public schemaRegistry;
    address public immutable OP_ATTESTATION_STATION;
    AttestationStation public atst;
    // Registry of DApps
    mapping(address => RegisterDappData) private registeredDapps; 


    // Constructor
    constructor(ISchemaRegistry _schemaRegistry, address _opAttestationStation) {
        schemaRegistry = _schemaRegistry;
        OP_ATTESTATION_STATION = _opAttestationStation;
        atst = AttestationStation(_opAttestationStation);
    }

    // Functions
    function getSchemaRegistry() external view override returns (ISchemaRegistry) {
        return schemaRegistry;
    }

    function registerDapp(RegisterDappData calldata _data) external {
        // DApp must not be registered already
        if (registeredDapps[_data.dapp].dapp != address(0)) {
            revert DappAlreadyRegistered();
        }

        // DApp or Registrar address must not be zero
        if (_data.dapp == address(0) || _data.registerer == address(0)) {
            revert ZeroAddress();
        }

        // Register the DApp
        registeredDapps[_data.dapp] = _data;

        // Emit event
        emit Registered(_data.dapp, _data.name, _data.registerer);
    }

    function getRegisteredDapp(address _dapp) external view returns (RegisterDappData memory) {
        return registeredDapps[_dapp];
    }

}