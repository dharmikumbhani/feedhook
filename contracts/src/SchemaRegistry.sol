// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import {ISchemaRegistry, SchemaRecord, SchemaAttestationRequest,SchemaAttestationData, AttestationData, AttestationRequestData} from "./ISchemaRegistry.sol";

// Errors
error SchemaAlreadyRegistered();
error SchemaNotRegistered();
error AttestationFailed();
error AttestationRetrievalFailed();
contract SchemaRegistry is ISchemaRegistry {
    // State
    mapping(bytes32 => SchemaRecord) public schemaRegistry;
    address public immutable ATTESTATION_STATION;
    constructor(address _attestationStation) {
        ATTESTATION_STATION = _attestationStation;
    }

    // Functions

    function registerSchema(SchemaRecord calldata _schemaRecord) external returns (bytes32) {
        SchemaRecord memory record = _schemaRecord;

        bytes32 uid = getUID(record);
        if(schemaRegistry[uid].uid != bytes32(0)) {
            revert SchemaAlreadyRegistered();
        }
        record.uid = uid;
        schemaRegistry[uid] = record;

        emit SchemaRegistered(uid, msg.sender, record.delegate, record.delegatable, record.schema);

        return uid;
    }

    function getSchema(bytes32 uid) external view returns (SchemaRecord memory record) {
        if(schemaRegistry[uid].uid == bytes32(0)) {
            revert SchemaNotRegistered();
        }
        return schemaRegistry[uid];
    }

    // Taken from the EAS SchemaRegistry.sol
    function getUID(SchemaRecord memory schemaRecord) private pure returns (bytes32 uid) {
        return keccak256(abi.encodePacked(schemaRecord.schema, schemaRecord.resolver, schemaRecord.revocable, schemaRecord.delegatable, schemaRecord.delegate));
    }

    // SchemaRegistry Ends Here
    // TODO: Move below to AttestationStationMiddleware

    // submitAttestation (for non-schema attestations)
    // TODO: Remove this, was only needed for testing. Users can directly call AttestationStation.sol
    function submitAttestation(AttestationData calldata _request) external {
        (bool success, ) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attest(address,bytes32,bytes)", _request.about, _request.key, _request.val));
        if(!success) {
            revert AttestationFailed();
        }
        emit AttestationSubmitted(_request.about, _request.key, _request.val);
    }

    // submitSchemaAttestation
    function submitSchemaAttestation(SchemaAttestationRequest calldata _request) external {

        SchemaAttestationRequest[] memory _requests = new SchemaAttestationRequest[](1);
        _requests[0] = _request;
        // Submit the attestation to AttestationStation.sol
        // _submitSchemaAttestation(_requests);
    }

    // function _submitSchemaAttestation(SchemaAttestationRequest[] memory _requests) private {

    //     for(uint256 i = 0; i < _requests.length; ) {
    //         if(schemaRegistry[_requests[i].schemaUID].uid == bytes32(0)) {
    //             revert SchemaNotRegistered();
    //         }

    //         bytes memory value = abi.encode(_requests[i].schemaUID, _requests[i].data, _requests[i].attester);


    //         (bool success, ) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attest(address,bytes32,bytes)", _requests[i].about, _requests[i].key, value));
            
    //         if(!success) {
    //             revert AttestationFailed();
    //         }

    //         emit SchemaAttestationSubmitted(_requests[i].schemaUID, _requests[i].about, _requests[i].key, _requests[i].data, _requests[i].attester);

    //         unchecked {
    //             ++i;
    //         }
    //     }
    // }

    // multiSubmitSchemaAttestation
    function multiSubmitSchemaAttestation(SchemaAttestationRequest[] calldata _requests) external {
        // Submit the attestation to AttestationStation.sol
        // _submitSchemaAttestation(_requests);
    }


    // getSchemaAttestation
    function getSchemaAttestation(address _attester, address _about, bytes32 _key) external returns (SchemaAttestationData memory) {
        // Get the attestation from AttestationStation.sol
        bytes memory value = _getSchemaAttestation(_attester, _about, _key);
        (bytes32 schemaUID, bytes memory data, address attester) = abi.decode(value, (bytes32, bytes, address));
        return SchemaAttestationData({
            uid: schemaUID,
            about: _about,
            key: _key,
            data: data,
            attester: attester
        });
    }

    function _getSchemaAttestation(address _attester, address _about, bytes32 _key) private returns (bytes memory) {
        (bool success, bytes memory value) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attestations(address,address,bytes32)", _attester, _about, _key));
        if(!success) {
            revert AttestationRetrievalFailed();
        }
        return abi.decode(value, (bytes));
    }

    /**
     * @dev Multicall for getting attestations
     * @param _requests Array of AttestationRequestData
     */
    function getMultipleAttestations(AttestationRequestData[] calldata _requests) external returns (bytes[] memory) {
        bytes[] memory _responses = new bytes[](_requests.length);
        for(uint256 i = 0; i < _requests.length; ) {
            bytes memory value = _getSchemaAttestation(_requests[i].attester, _requests[i].about, _requests[i].key);
            _responses[i] = value;
            unchecked {
                ++i;
            }
        }
        return _responses;
    }
}