// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MessageMain {

    event MessageReceived(bytes32 messageId, uint32 origin, bytes32 sender, bytes body);

    address mailbox; // address of mailbox contract

    constructor(address _mailbox){
        mailbox = _mailbox;
    }

    // handle function which is called by the mailbox to bridge messages from other chains
    function handle(uint32 _origin, bytes32 _sender, bytes memory _body) external {
    bytes32 messageId = keccak256(abi.encodePacked(_origin, _sender, _body));
    emit MessageReceived(messageId, _origin, _sender, _body);    }
}