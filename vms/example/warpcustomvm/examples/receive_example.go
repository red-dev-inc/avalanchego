// Copyright (C) 2019-2025, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

package main

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"

	"github.com/ava-labs/avalanchego/ids"
	"github.com/ava-labs/avalanchego/vms/example/warpcustomvm/api"
)

// Example demonstrates how to receive and query messages from C-Chain in warpcustomvm
func main() {
	// Create client
	blockchainID := "2EcxPo6BHr9xPcHrjLSgHLzzMtPVuKaKzWvSPDGJQgLkFxUzRQ"
	client := api.NewClient("http://localhost:9650", blockchainID)

	ctx := context.Background()

	fmt.Println("=== WarpCustomVM - Receive Messages Example ===\n")

	// Example 1: Receive a Warp message (normally done by relayer)
	fmt.Println("Example 1: Receive Warp Message from C-Chain")
	fmt.Println("---------------------------------------------")
	fmt.Println("Note: This is typically done by the ICM relayer automatically.")
	fmt.Println("Here's an example of the API call structure:\n")

	exampleSignedMessage := "0x..." // This would be the actual signed Warp message
	fmt.Printf("Sample receiveWarpMessage call with signed message:\n")
	fmt.Printf("  signedMessage: %s (truncated)\n\n", exampleSignedMessage[:20])

	// In production, you would call:
	// response, err := client.ReceiveWarpMessage(ctx, signedMessageHex)

	// Example 2: Query all received messages
	fmt.Println("Example 2: Get All Received Messages")
	fmt.Println("-------------------------------------")

	// Note: This method needs to be added to the client
	// For now, we'll show the JSON-RPC call structure
	fmt.Println("JSON-RPC Call:")
	fmt.Println(`{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "warpcustomvm.getAllReceivedMessages",
  "params": {}
}`)
	fmt.Println()

	// Example 3: Query chain information
	fmt.Println("Example 3: Get Chain Information")
	fmt.Println("---------------------------------")

	chainInfo, err := client.GetChainID(ctx)
	if err != nil {
		log.Printf("⚠️  Failed to get chain ID: %v\n", err)
	} else {
		fmt.Printf("✓ Chain information retrieved:\n")
		fmt.Printf("  Chain ID: %s\n", chainInfo.ChainID)
		fmt.Printf("  Network ID: %d\n\n", chainInfo.NetworkID)
	}

	// Example 4: Query a specific received message
	fmt.Println("Example 4: Get Specific Received Message")
	fmt.Println("-----------------------------------------")
	fmt.Println("First get message IDs from getAllReceivedMessages,")
	fmt.Println("then query individual messages by ID.\n")

	// Example message ID (in practice, you'd get this from getAllReceivedMessages)
	exampleMessageID, _ := ids.FromString("2HgU68fXLffrsXimkrSP4rmtSgEsbaCCNAvnH25JKCkQVXU1N1")
	fmt.Printf("Sample getReceivedMessage call:\n")
	fmt.Printf("  messageID: %s\n\n", exampleMessageID)

	// Example 5: Send a message (for comparison)
	fmt.Println("Example 5: Send Message to C-Chain (for comparison)")
	fmt.Println("----------------------------------------------------")

	// C-Chain blockchain ID on Fuji
	cChainID := "yH8D7ThNJkxmtkuv2jgBa4P1Rn3Qpr4pPr7QYNfcdoS6k6HWp"
	destinationAddress := "0x772eb420B677F0c42Dc1aC503D03E02E92ae1502"
	message := "Reply from WarpCustomVM!"

	fmt.Printf("Sending message to C-Chain:\n")
	fmt.Printf("  Destination: %s\n", cChainID)
	fmt.Printf("  Address: %s\n", destinationAddress)
	fmt.Printf("  Message: %s\n\n", message)

	// Uncomment to actually send:
	// messageID, err := client.SubmitMessage(ctx, cChainID, destinationAddress, message)
	// if err != nil {
	// 	log.Fatalf("Failed to submit message: %v", err)
	// }
	// fmt.Printf("✓ Message sent! ID: %s\n\n", messageID)

	// Example 6: Parse a signed Warp message (educational)
	fmt.Println("Example 6: Understanding Signed Warp Messages")
	fmt.Println("----------------------------------------------")
	fmt.Println("A signed Warp message contains:")
	fmt.Println("  1. Unsigned message (network ID, source chain, payload)")
	fmt.Println("  2. BLS aggregate signature from validators")
	fmt.Println("  3. Bitset indicating which validators signed")
	fmt.Println()
	fmt.Println("The payload contains an AddressedCall with:")
	fmt.Println("  - Source address (sender on C-Chain)")
	fmt.Println("  - Teleporter message (ABI-encoded payload)")
	fmt.Println()

	// Example workflow
	fmt.Println("\n=== Complete Workflow: C-Chain → WarpCustomVM ===\n")
	fmt.Println("1. Deploy WarpMessageSender.sol on C-Chain Fuji")
	fmt.Println("   - Teleporter: 0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf")
	fmt.Println()
	fmt.Println("2. Send message from C-Chain:")
	fmt.Println("   senderContract.sendMessage(")
	fmt.Printf("     \"%s\",  // WarpCustomVM blockchain ID\n", blockchainID)
	fmt.Println("     \"0x0200000000000000000000000000000000000005\",  // Warp precompile")
	fmt.Println("     \"Hello from C-Chain!\"")
	fmt.Println("   )")
	fmt.Println()
	fmt.Println("3. ICM Relayer:")
	fmt.Println("   - Detects message on C-Chain")
	fmt.Println("   - Collects validator signatures")
	fmt.Println("   - Calls warpcustomvm.receiveWarpMessage")
	fmt.Println()
	fmt.Println("4. Query received messages:")
	fmt.Println("   - getAllReceivedMessages() - List all")
	fmt.Println("   - getReceivedMessage(id) - Get details")
	fmt.Println()

	// Helper function examples
	fmt.Println("\n=== Helper Functions ===\n")
	showHexConversion()
	showMessageIDComputation()

	fmt.Println("\nFor more examples, see:")
	fmt.Println("  - RECEIVING_MESSAGES.md")
	fmt.Println("  - examples/receive_examples.sh")
	fmt.Println("  - contracts/WarpMessageSender.sol")
}

// showHexConversion demonstrates hex encoding/decoding
func showHexConversion() {
	fmt.Println("Hex Conversion:")
	fmt.Println("---------------")

	exampleBytes := []byte("Hello from C-Chain!")
	hexEncoded := hex.EncodeToString(exampleBytes)
	fmt.Printf("Text: %s\n", exampleBytes)
	fmt.Printf("Hex:  0x%s\n\n", hexEncoded)
}

// showMessageIDComputation demonstrates message ID calculation
func showMessageIDComputation() {
	fmt.Println("Message ID Computation:")
	fmt.Println("-----------------------")
	fmt.Println("Message ID = SHA256(unsigned_warp_message_bytes)")
	fmt.Println("This ensures unique identification of each message")
	fmt.Println()

	// Example structure
	type ExampleWarpMessage struct {
		NetworkID     uint32 `json:"networkID"`
		SourceChainID string `json:"sourceChainID"`
		Payload       string `json:"payload"`
	}

	example := ExampleWarpMessage{
		NetworkID:     5, // Fuji
		SourceChainID: "yH8D7ThNJkxmtkuv2jgBa4P1Rn3Qpr4pPr7QYNfcdoS6k6HWp",
		Payload:       "0x...",
	}

	exampleJSON, _ := json.MarshalIndent(example, "  ", "  ")
	fmt.Printf("Example unsigned message structure:\n%s\n", exampleJSON)
	fmt.Println()
}
