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

    function registerDapp(address _dapp, string calldata _name, address _registerer) external {
        // DApp must not be registered already
        if (registeredDapps[_dapp].dapp != address(0)) {
            revert DappAlreadyRegistered();
        }

        // DApp or Registrar address must not be zero
        if (_dapp == address(0) || _registerer == address(0)) {
            revert ZeroAddress();
        }

        RegisterDappData memory _data = RegisterDappData({
            registerer: _registerer,
            dapp: _dapp,
            name: _name
        });
        // Register the DApp
        registeredDapps[_dapp] = _data;

        // Emit event
        emit Registered(_dapp, _name, _registerer);
    }

    function getRegisteredDapp(address _dapp) external view returns (RegisterDappData memory) {
        if (registeredDapps[_dapp].dapp == address(0)) {
            revert UnregisteredDapp();
        }
        return registeredDapps[_dapp];
    }

}