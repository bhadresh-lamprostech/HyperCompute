// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@hyperlane-xyz/core/contracts/interfaces/IInterchainGasPaymaster.sol";
import "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";

contract MessageRouter {
    // Variables to store important contract addresses and domain identifiers
    address mailbox;
    address interchainGasPaymaster;
    uint32 domainId;
    address messageContract;

    uint nonce;

    struct contractInfo {
        address sourceAddress;
        string sourceFunction;
    }

    mapping(bytes32 => contractInfo) uuidToContractInfo;

    event dispatchCallCreated(
        bytes32 uuid,
        address indexed Executer,
        bytes callData
    );

    event CallbackCreated(bytes32 uuid, string sourceFunction, bytes data);

    constructor(
        address _mailbox,
        address _interchainGasPaymaster,
        uint32 _domainId,
        address _messageContract
    ) {
        mailbox = _mailbox;
        interchainGasPaymaster = _interchainGasPaymaster;
        domainId = _domainId;
        messageContract = _messageContract;
    }

    // By calling this function you can send a message to other chain
    function sendMessage(
        bytes memory _byteCode,
        bytes calldata _encodedFunctionData
    ) external payable {
        bytes32 uuid = keccak256(
            abi.encodePacked(block.number, msg.data, nonce++)
        );
        uuidToContractInfo[uuid];
        bytes memory callData = abi.encode(
            uuid,
            _byteCode,
            _encodedFunctionData,
            address(this)
        );
        bytes32 messageId = IMailbox(mailbox).dispatch(
            domainId,
            addressToBytes32(messageContract),
            callData
        );
        uint256 quoteValue = getGasQuote();
        IInterchainGasPaymaster(interchainGasPaymaster).payForGas{
            value: quoteValue
        }(messageId, domainId, 1009736, msg.sender);
        emit dispatchCallCreated(uuid, msg.sender, callData);
    }

    // Function to get the gas quote from the paymaster contract
    function getGasQuote() internal view returns (uint256) {
        return
            IInterchainGasPaymaster(interchainGasPaymaster).quoteGasPayment(
                domainId,
                1009736
            );
    }

    // Converts address to bytes32
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function withdraw() external {
        uint256 balance = address(this).balance;
        require(balance > 0, "Contract balance is zero");
        payable(msg.sender).transfer(balance);
    }
}
