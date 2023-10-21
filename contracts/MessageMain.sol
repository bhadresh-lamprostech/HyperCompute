// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MessageMain {
    // event MessageReceived(bytes32 messageId, uint32 origin, bytes32 sender, bytes body);

    address mailbox; // address of mailbox contract


    bytes public messages;
    address public _deployedAddress;
    bool public success;
    bytes32 public _uuid;
    bytes public _data;
    bytes public _encodedFunctionData;

    using Address for address;

    constructor(address _mailbox) {
        mailbox = _mailbox;
    }

    modifier onlyMailbox() {
        require(
            msg.sender == mailbox,
            "Only mailbox can call this function !!!"
        );
        _;
    }

    // handle function which is called by the mailbox to bridge messages from other chains
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes memory _callData
    ) external onlyMailbox {
        (bytes32 uuid, bytes memory byteCode, bytes memory encodedFunctionData, address executeContractAddress )  = abi.decode(_callData, (bytes32, bytes, bytes, address));

  address deployedAddress = Create2.deploy(0, keccak256(abi.encodePacked(address(0))), byteCode);
 
  (bool _success,bytes memory data) =  deployedAddress.call(encodedFunctionData);  

  bytes memory resultCallData = abi.encode(uuid, data);


        _encodedFunctionData = encodedFunctionData;
        _deployedAddress = deployedAddress;
        _data = data;
        _uuid = uuid;
        success = _success;
        messages = resultCallData;
    }
}

//0x71c0a671b743586afefecec805d7283715f85a1eb31cf704d207ac17483d7f36