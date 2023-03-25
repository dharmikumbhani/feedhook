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
    event SubmittedDelegatedSchemaAttestation(address indexed about, bytes32 indexed key, address indexed delegate, bytes data, address attester);

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

            address delegate = schemaRecord.delegate; // This is the address that attests on behalf of the _requests[i].attester

            // Check if the delegate is the msg.sender
            if(delegate != msg.sender && delegate != address(0)) { // If delegate is 0 address then anyone can attest on behalf of the attester.
                revert UnauthorizedSchemaAttestation();
            }
            // Now delegate can be 0 address or the msg.sender
            
            // Add a check to see if Request.delegate is same as schemaRecord.delegate. Is this necessary? As it is already in the message signed by the attester.
            if(_requests[i].delegate != delegate) {
                revert UnauthorizedSchemaAttestation();
            }
            // Verify the signature.
            _verifyAttestation(_requests[i]);

            // Verified! Submit the attestation to AttestationStation.sol
            bytes memory value = abi.encode(_requests[i].uid, _requests[i].data, _requests[i].attester); // msg.sender is the attester as this is not a delegated schema attestation.

            (bool success, ) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attest(address,bytes32,bytes)", _requests[i].about, _requests[i].key, value));

            if(!success) {
                revert AttestationFailed();
            }

            // Emit event for delegated schema attestation
            emit SubmittedDelegatedSchemaAttestation(_requests[i].about, _requests[i].key, _requests[i].delegate, value, _requests[i].attester);
        }
    }

    // submitDelegatedSchemaAttestation
    function submitDelegatedSchemaAttestation(DelegatedSchemaAttestationRequest calldata _request) external {
        
            DelegatedSchemaAttestationRequest[] memory _requests = new DelegatedSchemaAttestationRequest[](1);
            _requests[0] = _request;
            // Submit the attestation to AttestationStation.sol
            _submitDelegatedSchemaAttestation(_requests);
    }

    // verifyAttestation
    function verifyAttestation(DelegatedSchemaAttestationRequest calldata _request) external returns (bool) {
        // Verify the signature.
        _verifyAttestation(_request);
        return true;
    }
    

}