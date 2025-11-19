// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/ITeleporterMessenger.sol";
import "@teleporter/ITeleporterReceiver.sol";

contract ReceiverOnSubnet is ITeleporterReceiver {
    ITeleporterMessenger public immutable teleporterMessenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

    struct ReceivedMessage {
        address sender;
        bytes32 sourceBlockchainID;
        uint256 nonce;
        bytes payload;
        uint256 receivedAt;
        bool exists;
    }

    mapping(bytes32 => ReceivedMessage) private messages;
    bytes32[] private messageIds;

    event MessageReceived(
        bytes32 indexed messageId,
        bytes32 indexed sourceBlockchainID,
        address indexed sender,
        uint256 nonce,
        bytes payload
    );

    event MessageProcessed(bytes32 indexed messageId, bool success);

    constructor(address _teleporterMessenger) {
        require(_teleporterMessenger != address(0), "Invalid teleporter address");
        teleporterMessenger = ITeleporterMessenger(_teleporterMessenger);
    }

    function receiveTeleporterMessage(
        bytes32 sourceBlockchainID,
        address originSenderAddress,
        bytes calldata message
    ) external override {
        require(msg.sender == address(teleporterMessenger), "Only Teleporter");

        uint256 nonce = messageIds.length;
        bytes32 messageId = keccak256(
            abi.encodePacked(sourceBlockchainID, originSenderAddress, nonce, block.timestamp)
        );

        messages[messageId] = ReceivedMessage({
            sender: originSenderAddress,
            sourceBlockchainID: sourceBlockchainID,
            nonce: nonce,
            payload: message,
            receivedAt: block.timestamp,
            exists: true
        });

        messageIds.push(messageId);
        emit MessageReceived(messageId, sourceBlockchainID, originSenderAddress, nonce, message);
        emit MessageProcessed(messageId, true);
    }

    function getMessage(bytes32 messageId)
        external
        view
        returns (
            address sender,
            bytes32 sourceBlockchainID,
            uint256 nonce,
            bytes memory payload,
            uint256 receivedAt
        )
    {
        ReceivedMessage storage receivedMsg = messages[messageId];
        require(receivedMsg.exists, "Message not found");
        return (receivedMsg.sender, receivedMsg.sourceBlockchainID, receivedMsg.nonce, receivedMsg.payload, receivedMsg.receivedAt);
    }

    function getMessagePayload(bytes32 messageId) external view returns (bytes memory) {
        require(messages[messageId].exists, "Message not found");
        return messages[messageId].payload;
    }

    function getMessagePayloadAsString(bytes32 messageId) external view returns (string memory) {
        require(messages[messageId].exists, "Message not found");
        return string(messages[messageId].payload);
    }

    function getAllMessageIds() external view returns (bytes32[] memory) {
        return messageIds;
    }

    function getMessageCount() external view returns (uint256) {
        return messageIds.length;
    }

    function getLatestMessageId() external view returns (bytes32) {
        require(messageIds.length > 0, "No messages");
        return messageIds[messageIds.length - 1];
    }

    function getMessageIdByIndex(uint256 index) external view returns (bytes32) {
        require(index < messageIds.length, "Index out of bounds");
        return messageIds[index];
    }

    function messageExists(bytes32 messageId) external view returns (bool) {
        return messages[messageId].exists;
    }
}
