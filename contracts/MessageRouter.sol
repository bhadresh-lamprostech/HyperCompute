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

    constructor(address _mailbox, address _interchainGasPaymaster, uint32 _domainId, address _messageContract) {
        mailbox = _mailbox;
        interchainGasPaymaster = _interchainGasPaymaster;
        domainId = _domainId;
        messageContract = _messageContract;
    }

    // By calling this function you can send a message to other chain
   function sendMessage(bytes memory _body) payable external {
        bytes32 messageId = IMailbox(mailbox).dispatch(domainId, addressToBytes32(messageContract), _body);
        uint256 quoteValue = getGasQuote();
        IInterchainGasPaymaster(interchainGasPaymaster).payForGas{value: quoteValue}(
            messageId,
            domainId,
            209736,
            msg.sender
        );
    }

    // Function to get the gas quote from the paymaster contract
    function getGasQuote() internal view returns (uint256) {
        return IInterchainGasPaymaster(interchainGasPaymaster).quoteGasPayment(domainId, 209736);
    }

    // Converts address to bytes32
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}