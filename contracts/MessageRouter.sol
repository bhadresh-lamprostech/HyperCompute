// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@hyperlane-xyz/core/contracts/interfaces/IInterchainGasPaymaster.sol";
import "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MessageRouter {
    // Variables to store important contract addresses and domain identifiers
    address senderMailbox;
    address receiverMailbox;
    address senderInterchainGasPaymaster;
    uint32 senderDomainId;
    address messageMainContract;

    bytes32 public _uuid;
    bytes public _data;

    uint nonce;

    modifier onlyMailbox() {
        require(
            msg.sender == receiverMailbox,
            "Only mailbox can call this function !!!"
        );
        _;
    }

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
        address _senderMailbox,
        address _receiverMailbox,
        address _senderInterchainGasPaymaster,
        uint32 _senderDomainId,
        address _messageMainContract
    ) {
        senderMailbox = _senderMailbox;
        receiverMailbox = _receiverMailbox;
        senderInterchainGasPaymaster = _senderInterchainGasPaymaster;
        senderDomainId = _senderDomainId;
        messageMainContract = _messageMainContract;
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
        bytes32 messageId = IMailbox(senderMailbox).dispatch(
            senderDomainId,
            addressToBytes32(messageMainContract),
            callData
        );
        uint256 quoteValue = getGasQuote();
        IInterchainGasPaymaster(senderInterchainGasPaymaster).payForGas{
            value: quoteValue
        }(messageId, senderDomainId, 1009736, msg.sender);
        emit dispatchCallCreated(uuid, msg.sender, callData);
    }

    // Function to get the gas quote from the paymaster contract
    function getGasQuote() internal view returns (uint256) {
        return
            IInterchainGasPaymaster(senderInterchainGasPaymaster)
                .quoteGasPayment(senderDomainId, 1009736);
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

    // handle function which is called by the mailbox to bridge messages from other chains
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes memory _result
    ) external onlyMailbox {
        (bytes32 uuid, bytes memory data) = abi.decode(_result,(bytes32, bytes));
        _uuid = uuid;
        _data = data;
    }
}
