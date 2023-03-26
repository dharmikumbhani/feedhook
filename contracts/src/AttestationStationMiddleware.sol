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
error VerifyingWithNonZeroDelegate();
error VerifyingWithWrongDelegate();

contract AttestationStationMiddleware is AttestationVerifier{
    // State
    address public immutable ATTESTATION_STATION;
    ISchemaRegistry public immutable SCHEMA_REGISTRY;

    // Events
    event AttestationSubmitted(address indexed about, bytes32 indexed key, bytes val);
    /**
     * @dev Emitted when a schema attestation is submitted.
     * @notice about, key and attester are indexed to retrieve the attestation[attester][about][key] from AttestationStation
     */
    event SchemaAttestationSubmitted(bytes32 schemaUID, address indexed about, bytes32 indexed key, bytes data, address indexed attester);
    /**
     * @dev Emitted when a delegated schema attestation is submitted.
     * @notice about, key and delegate are indexed to retrieve the attestation[delegate][about][key] from AttestationStation
     */
    event SubmittedDelegatedSchemaAttestation(address indexed about, bytes32 indexed key, address indexed delegate, bytes data, address attester);

    constructor(address _atst, address _schemaRegistry) AttestationVerifier("Attestation Station Middleware", "0.0.1") {
        ATTESTATION_STATION = _atst;
        SCHEMA_REGISTRY = ISchemaRegistry(_schemaRegistry);
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

    /**
     * @dev private function to submit schema attestations to AttestationStation
     * @param _requests Array of SchemaAttestationRequest
     */

    function _submitSchemaAttestation(SchemaAttestationRequest[] memory _requests) private {

        for(uint256 i = 0; i < _requests.length; ) {

            SchemaRecord memory schemaRecord = SCHEMA_REGISTRY.getSchema(_requests[i].uid);

            // Check if schema is registered
            if(schemaRecord.uid == bytes32(0)) {
                revert SchemaNotRegistered();
            }
            
            // uid, data and attester are encoded into bytes and submitted to AttestationStation
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

    /**
     * @dev submitSchemaAttestation - Submit a schema attestation to AttestationStation
     * @param _request SchemaAttestationRequest
     */
    function submitSchemaAttestation(SchemaAttestationRequest calldata _request) external {

        SchemaAttestationRequest[] memory _requests = new SchemaAttestationRequest[](1);
        _requests[0] = _request;
        // Submit the attestation to AttestationStation.sol
        _submitSchemaAttestation(_requests);
    }

    /**
     * @dev submitMultipleSchemaAttestations - Submit multiple schema attestations to AttestationStation
     * @param _requests Array of SchemaAttestationRequest
     */
    function submitMultipleSchemaAttestations(SchemaAttestationRequest[] calldata _requests) external {

        // Submit the attestation to AttestationStation.sol
        _submitSchemaAttestation(_requests);
    }


    /**
     * @dev _submitDelegatedSchemaAttestation - Private for submitting a delegated schema attestations to AttestationStation
     * @param _requests DelegatedSchemaAttestationRequest
     */
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
            if(delegate != msg.sender) {
                revert UnauthorizedSchemaAttestation();
            }
            
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

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev submitDelegatedSchemaAttestation - Submit an off-chain delegated schema attestation to AttestationStation
     * @param _request DelegatedSchemaAttestationRequest
     */
    function submitDelegatedSchemaAttestation(DelegatedSchemaAttestationRequest calldata _request) external {
        
            DelegatedSchemaAttestationRequest[] memory _requests = new DelegatedSchemaAttestationRequest[](1);
            _requests[0] = _request;
            // Submit the attestation to AttestationStation.sol
            _submitDelegatedSchemaAttestation(_requests);
    }

    /**
     * @dev submitMultipleDelegatedSchemaAttestations - Submit multiple off-chain delegated schema attestations to AttestationStation
     * @param _requests Array of DelegatedSchemaAttestationRequest
     */
    function submitMultipleDelegatedSchemaAttestations(DelegatedSchemaAttestationRequest[] calldata _requests) external {
        // Submit the attestation to AttestationStation.sol
        _submitDelegatedSchemaAttestation(_requests);
    }

    /**
     * @dev verifyAttestation - Verify an off-chain delegated schema attestation
     * @param _request DelegatedSchemaAttestationRequest
     * @return bool - true if attestation is verified successfully
     * @dev Schema's where delegatable is false can also be verified using this function. If the _request.delegate address is the zero address.
     * @dev _attestation.delegate should be same as the delegate in the schemaRecord and also the same while signing the message else signature will be invalid.
     */
    function verifyAttestation(DelegatedSchemaAttestationRequest calldata _request) external returns (bool) {
        // Check if schema is registered
        SchemaRecord memory schemaRecord = SCHEMA_REGISTRY.getSchema(_request.uid);
        if(schemaRecord.uid == bytes32(0)) {
            revert SchemaNotRegistered();
        }
        /**
         * @dev If the schema is not delegatable then it can be verified by anyone but the delegate address must be the zero address; As it is the zero address in the schemaRecord.
         */
        if(schemaRecord.delegatable == false && _request.delegate != address(0)) {
            revert VerifyingWithNonZeroDelegate();
        }
        /**
         * @dev If the schema is delegatable and the delegate address is not the zero address then the delegate address must be the same as the one in the schemaRecord.
         */
        if(schemaRecord.delegatable == true && _request.delegate != schemaRecord.delegate) {
            revert VerifyingWithWrongDelegate();
        }
        // Verify the signature.
        _verifyAttestation(_request);
        return true;
    }

    /**
     * @dev getAttestations - Multicall for getting attestations from AttestationStation
     * @param _requests Array of AttestationRequestData
     */
    function getAttestations(AttestationRequestData[] calldata _requests) external returns (bytes[] memory) {
        bytes[] memory _responses = new bytes[](_requests.length);
        for(uint256 i = 0; i < _requests.length; ) {
            (bool success, bytes memory response) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attestations(address,address,bytes32)", _requests[i].attester, _requests[i].about, _requests[i].key));
            if(!success) {
                revert AttestationRetrievalFailed();
            }
            _responses[i] = abi.decode(response, (bytes));
            unchecked {
                ++i;
            }
        }
        return _responses;
    }

    /**
     * @dev Get schema attestations from AttestationStation
     * @dev AttestationRequestData.attester will be the delegate's address if attestation was off-chain before.
     * @param _requests array of AttestationRequestData
     * @return bytes array of bytes
     */
    function _getSchemaAttestations(AttestationRequestData[] memory _requests) private returns (bytes[] memory) {
        bytes[] memory _responses = new bytes[](_requests.length);
        for(uint256 i = 0; i < _requests.length; ) {
            (bool success, bytes memory response) = ATTESTATION_STATION.delegatecall(abi.encodeWithSignature("attestations(address,address,bytes32)", _requests[i].attester, _requests[i].about, _requests[i].key));
            if(!success) {
                revert AttestationRetrievalFailed();
            }
            _responses[i] = abi.decode(response, (bytes));
            unchecked {
                ++i;
            }
        }
        return _responses;
    }

    /**
     * @dev Get schema attestation from AttestationStation
     * @dev AttestationRequestData.attester will be the delegate's address if attestation was off-chain before.
     * @param _request AttestationRequestData
     * @return SchemaAttestationData
     */
    function getSchemaAttestation(AttestationRequestData calldata _request) external returns (SchemaAttestationData memory) {
        AttestationRequestData[] memory _requests = new AttestationRequestData[](1);
        _requests[0] = _request;
        bytes[] memory _responses = _getSchemaAttestations(_requests);
        (bytes32 schemaUID, bytes memory data, address attester) = abi.decode(_responses[0], (bytes32, bytes, address));
        // data should further be decoded.
        return SchemaAttestationData({
            uid: schemaUID,
            data: data,
            attester: attester,
            about: _request.about,
            key: _request.key
        });
    }


    /**
     * @dev Get multiple schema attestations from AttestationStation
     * @param _requests array of AttestationRequestData
     * @return responses - array of bytes
     * @dev Decode bytes like this abi.decode(_responses[0], (bytes32, bytes, address)); where bytes32 is the schemaUID, bytes is the data and address is the attester.
     */
    function getMultipleSchemaAttestations(AttestationRequestData[] calldata _requests) external returns (bytes[] memory) {
        bytes[] memory _responses = _getSchemaAttestations(_requests);
        return _responses;
    }
    

}