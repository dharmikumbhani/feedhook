/**
 * @title Attestation Station Middleware
 */

pragma solidity 0.8.15;

// Imports
import "./SchemaRegistry.sol";
import {AttestationVerifier} from "./AttestationVerifier.sol";
import {ISchemaRegistry, SchemaRecord, SchemaAttestationRequest, AttestationData, AttestationRequestData, DelegatedSchemaAttestationRequest} from "./ISchemaRegistry.sol";
// Errors
error UnauthorizedSchemaAttestation();
error SchemaNotDelegatable();
contract AttestationStationMiddleware is AttestationVerifier{
    // State
    address public immutable ATTESTATION_STATION;
    string public  NAME = "Attestation Station Middleware";
    string public VERSION = "0.0.1";
    ISchemaRegistry public immutable SCHEMA_REGISTRY;

    // Events
    event AttestationSubmitted(address indexed about, bytes32 indexed key, bytes val);
    /**
     * @dev Emitted when a schema attestation is submitted.
     * @notice about, key and attester are indexed to retrieve the attestation[attester][about][key] from AttestationStation.sol
     */
    event SchemaAttestationSubmitted(bytes32 schemaUID, address indexed about, bytes32 indexed key, bytes data, address indexed attester);

    constructor(address _atst, ISchemaRegistry _schemaRegistry) AttestationVerifier(NAME, VERSION) {
        ATTESTATION_STATION = _atst;
        SCHEMA_REGISTRY = _schemaRegistry;
    }
    // Functions
    // TODO: Remove this, was only needed for testing. Users can directly call AttestationStation.sol
    function submitAttestation(AttestationData calldata _request) external {
        (bool success, ) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attest(address,bytes32,bytes)", _request.about, _request.key, _request.val));
        if(!success) {
            revert AttestationFailed();
        }
        emit AttestationSubmitted(_request.about, _request.key, _request.val);
    }

    function _submitSchemaAttestation(SchemaAttestationRequest[] memory _requests) private {

        for(uint256 i = 0; i < _requests.length; ) {

            SchemaRecord memory schemaRecord = SCHEMA_REGISTRY.getSchema(_requests[i].uid);

            // Check if schema is registered
            if(schemaRecord.uid == bytes32(0)) {
                revert SchemaNotRegistered();
            }

            bytes memory value = abi.encode(_requests[i].uid, _requests[i].data, msg.sender); // msg.sender is the attester as this is not a delegated schema attestation.


            (bool success, ) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attest(address,bytes32,bytes)", _requests[i].about, _requests[i].key, value));
            
            if(!success) {
                revert AttestationFailed();
            }

            emit SchemaAttestationSubmitted(_requests[i].uid, _requests[i].about, _requests[i].key, _requests[i].data, msg.sender);

            unchecked {
                ++i;
            }
        }
    }

    // submitSchemaAttestation
    function submitSchemaAttestation(SchemaAttestationRequest calldata _request) external {

        SchemaAttestationRequest[] memory _requests = new SchemaAttestationRequest[](1);
        _requests[0] = _request;
        // Submit the attestation to AttestationStation.sol
        _submitSchemaAttestation(_requests);
    }

    // submitMultipleSchemaAttestations
    function submitMultipleSchemaAttestations(SchemaAttestationRequest[] calldata _requests) external {

        // Submit the attestation to AttestationStation.sol
        _submitSchemaAttestation(_requests);
    }


    // _submitDelegatedSchemaAttestation
    function _submitDelegatedSchemaAttestation(DelegatedSchemaAttestationRequest[] memory _requests) private {

        for(uint256 i = 0; i < _requests.length; ) {

            SchemaRecord memory schemaRecord = SCHEMA_REGISTRY.getSchema(_requests[i].uid);

            // Check if schema is registered
            if(schemaRecord.uid == bytes32(0)) {
                revert SchemaNotRegistered();
            }

            if(schemaRecord.delegatable == false) {
                revert SchemaNotDelegatable(); // Attempting to submit a undelegated schema attestation.
            }

            bytes memory value = abi.encode(_requests[i].uid, _requests[i].data, _requests[i].attester); // msg.sender is the attester as this is not a delegated schema attestation.
        }
    }

    // submitDelegatedSchemaAttestation
    function submitDelegatedSchemaAttestation(DelegatedSchemaAttestationRequest calldata _request) external {

    }
    

}