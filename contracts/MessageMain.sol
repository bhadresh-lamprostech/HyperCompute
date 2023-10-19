// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MessageMain {

    event MessageReceived(bytes32 messageId, uint32 origin, bytes32 sender, bytes body);

    address mailbox; // address of mailbox contract

    bytes public messages;

    constructor(address _mailbox){
        mailbox = _mailbox;
    }

    modifier onlyMailbox(){ 
        require(msg.sender == mailbox, "Only mailbox can call this function !!!");
        _;
    }

    // handle function which is called by the mailbox to bridge messages from other chains
    function handle(uint32 _origin, bytes32 _sender, bytes memory _body) external onlyMailbox {
        messages = _body;
    }


}