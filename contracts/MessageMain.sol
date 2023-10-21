// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@hyperlane-xyz/core/contracts/interfaces/IInterchainGasPaymaster.sol";
import "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MessageMain {
    // event MessageReceived(bytes32 messageId, uint32 origin, bytes32 sender, bytes body);

    address senderMailbox;
    address receiverMailbox;
    address receiverInterchainGasPaymaster;
    uint32 receiverDomainId;
    address messageRouterContract;
    uint nonce;

    bytes public result;
    address public _deployedAddress;
    bool public success;
    bytes32 public _uuid;
    bytes public _data;
    bytes public _encodedFunctionData;

    using Address for address;

    constructor(
        address _senderMailbox,
        address _receiverMailbox,
        address _receiverInterchainGasPaymaster,
        uint32 _receiverDomainId
    ) {
        senderMailbox = _senderMailbox;
        receiverMailbox = _receiverMailbox;
        receiverInterchainGasPaymaster = _receiverInterchainGasPaymaster;
        receiverDomainId = _receiverDomainId;
    }

    modifier onlyMailbox() {
        require(
            msg.sender == senderMailbox,
            "Only mailbox can call this function !!!"
        );
        _;
    }

    event dispatchCallCreated(address indexed Executer, bytes _result);

    // handle function which is called by the mailbox to bridge messages from other chains
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes memory _callData
    ) external onlyMailbox {
        (
            bytes32 uuid,
            bytes memory byteCode,
            bytes memory encodedFunctionData,
            address executeContractAddress
        ) = abi.decode(_callData, (bytes32, bytes, bytes, address));

        address deployedAddress = Create2.deploy(
            0,
            keccak256(abi.encodePacked(address(0))),
            byteCode
        );

        (bool _success, bytes memory data) = deployedAddress.call(
            encodedFunctionData
        );

        bytes memory resultCallData = abi.encode(uuid, data);

        messageRouterContract = executeContractAddress;
        _encodedFunctionData = encodedFunctionData;
        _deployedAddress = deployedAddress;
        _data = data;
        _uuid = uuid;
        success = _success;
        result = resultCallData;
    }

    function sendResult(bytes memory _result) external payable {
        bytes32 messageId = IMailbox(receiverMailbox).dispatch(
            receiverDomainId,
            addressToBytes32(messageRouterContract),
            _result
        );
        uint256 quoteValue = getGasQuote();
        IInterchainGasPaymaster(receiverInterchainGasPaymaster).payForGas{
            value: quoteValue
        }(messageId, receiverDomainId, 1009736, msg.sender);
        emit dispatchCallCreated(msg.sender, _result);
    }

    // Function to get the gas quote from the paymaster contract
    function getGasQuote() internal view returns (uint256) {
        return
            IInterchainGasPaymaster(receiverInterchainGasPaymaster)
                .quoteGasPayment(receiverDomainId, 1009736);
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
