#!/bin/bash

# Example script demonstrating how to receive messages from C-Chain in warpcustomvm
# This script shows the complete workflow for testing message reception

set -e

# Configuration
BLOCKCHAIN_ID="2EcxPo6BHr9xPcHrjLSgHLzzMtPVuKaKzWvSPDGJQgLkFxUzRQ"
RPC_URL="http://localhost:9650/ext/bc/${BLOCKCHAIN_ID}/rpc"

echo "========================================="
echo "WarpCustomVM - Receive Message Examples"
echo "========================================="
echo ""
echo "⚠️  IMPORTANT: ICM Relayer handles message delivery automatically!"
echo "    You don't need to manually call receiveWarpMessage in production."
echo "    These examples show the API structure for understanding."
echo ""

# Example 1: Receive a Warp message (this would normally be done by the relayer)
echo "Example 1: Receive Warp Message (Called by ICM Relayer)"
echo "--------------------------------------------------------"
echo "This endpoint accepts a signed Warp message from another chain (like C-Chain)"
echo "The ICM relayer automatically calls this when delivering messages."
echo ""
echo "Request:"
cat << 'EOF'
curl -X POST ${RPC_URL} \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "warpcustomvm.receiveWarpMessage",
    "params": {
      "signedMessage": "0x<SIGNED_WARP_MESSAGE_HEX_FROM_CCHAIN>"
    }
  }'
EOF
echo ""
echo "Note: In production, the ICM relayer automatically calls this endpoint"
echo "      to deliver signed messages from source chains."
echo ""

# Example 2: Query all received messages
echo "Example 2: Get All Received Messages"
echo "-------------------------------------"
curl -X POST ${RPC_URL} \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "warpcustomvm.getAllReceivedMessages",
    "params": {}
  }' 2>/dev/null | jq '.'

echo ""
echo ""

# Example 3: Get chain ID (for reference)
echo "Example 3: Get Chain Information"
echo "---------------------------------"
curl -X POST ${RPC_URL} \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "warpcustomvm.getChainID",
    "params": {}
  }' 2>/dev/null | jq '.'

echo ""
echo ""

# Example 4: Query specific received message (if any exist)
echo "Example 4: Get Specific Received Message"
echo "-----------------------------------------"
echo "First, get message IDs from getAllReceivedMessages, then query individual messages:"
echo ""
echo "Request:"
cat << 'EOF'
curl -X POST ${RPC_URL} \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "warpcustomvm.getReceivedMessage",
    "params": {
      "messageID": "<MESSAGE_ID_FROM_PREVIOUS_RESPONSE>"
    }
  }'
EOF
echo ""
echo ""

# Example 5: Show how to send from this VM (for comparison)
echo "Example 5: Send Message from WarpCustomVM to C-Chain"
echo "-----------------------------------------------------"
echo "For comparison, here's how to send messages FROM warpcustomvm:"
echo ""
echo "Request:"
cat << 'EOF'
curl -X POST ${RPC_URL} \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "warpcustomvm.submitMessage",
    "params": {
      "destinationChain": "0x7fc93d85c6d62c5b2ac0b519c87010ea5294012d1e407030d6acd0021cac10d5",
      "destinationAddress": "0x772eb420B677F0c42Dc1aC503D03E02E92ae1502",
      "message": "Reply from WarpCustomVM!"
    }
  }'
EOF
echo ""
echo ""

echo "========================================="
echo "Testing Workflow with ICM Relayer"
echo "========================================="
echo ""
echo "To test receiving messages from C-Chain:"
echo ""
echo "1. Deploy WarpMessageSender.sol on C-Chain Fuji"
echo "   - Use Remix or Hardhat"
echo "   - Teleporter address: 0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf"
echo ""
echo "2. Configure ICM Relayer"
echo "   - Add C-Chain as source blockchain"
echo "   - Add WarpCustomVM as destination blockchain"
echo "   - Specify sender contract address"
echo "   - See ICM_RELAYER_CONFIG.md for complete setup"
echo ""
echo "3. Start ICM Relayer"
echo "   export RELAYER_PRIVATE_KEY=\"0x...\""
echo "   ./awm-relayer --config-file relayer-config.json"
echo ""
echo "4. Send a message from C-Chain:"
echo "   senderContract.sendMessage("
echo "     \"0x<WARPCUSTOMVM_BLOCKCHAIN_ID>\","
echo "     \"0x0200000000000000000000000000000000000005\","
echo "     \"Hello from C-Chain!\""
echo "   )"
echo ""
echo "5. Relayer automatically delivers (watch relayer logs)"
echo "   - Detects message on C-Chain"
echo "   - Collects validator signatures"
echo "   - Calls receiveWarpMessage on warpcustomvm"
echo ""
echo "6. Query received messages using getAllReceivedMessages"
echo ""
echo "7. Verify message details using getReceivedMessage"
echo ""

echo "========================================="
echo "Key Addresses"
echo "========================================="
echo ""
echo "Teleporter on C-Chain Fuji:"
echo "  0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf"
echo ""
echo "Warp Precompile (destination for messages to warpcustomvm):"
echo "  0x0200000000000000000000000000000000000005"
echo ""
echo "C-Chain Blockchain ID (Fuji):"
echo "  yH8D7ThNJkxmtkuv2jgBa4P1Rn3Qpr4pPr7QYNfcdoS6k6HWp"
echo "  Hex: 0x7fc93d85c6d62c5b2ac0b519c87010ea5294012d1e407030d6acd0021cac10d5"
echo ""

echo "For more details, see RECEIVING_MESSAGES.md"
echo ""
