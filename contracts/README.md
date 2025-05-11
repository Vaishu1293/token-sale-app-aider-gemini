# AIDER Token (AID) Smart Contract

This directory contains the Solidity smart contracts for the AIDER Token project, developed using Foundry.

## Features

-   **ERC20 Token**:
    -   Name: AIDER
    -   Symbol: AID
    -   Decimals: 18 (standard)
-   **Ownable**: Contract ownership is managed using OpenZeppelin's `Ownable` pattern, restricting administrative functions (like withdrawing ETH) to the owner.
-   **Token Sale (`buyTokens` function)**:
    -   Users can purchase AIDER tokens by sending ETH to the `buyTokens()` payable function.
    -   **Price**: 1 AID token costs 0.1 ETH.
    -   The contract mints the calculated number of tokens directly to the buyer (`msg.sender`).
    -   **Refunds**: If a user sends more ETH than is required for an integer number of tokens at the current price, the excess ETH is automatically refunded to the buyer in the same transaction.
-   **Withdraw ETH (`withdraw` function)**:
    -   The contract owner can withdraw the total ETH balance accumulated in the contract (from token sales) to their own address.
-   **Receive ETH**: The contract includes a `receive()` external payable function, allowing it to accept direct ETH transfers (e.g., for donations, although `buyTokens` is the primary mechanism for sending ETH to the contract).

## Contracts Overview

-   **`src/AiderToken.sol`**: This is the core smart contract. It implements the ERC20 token standard (inheriting from OpenZeppelin's `ERC20.sol`) and includes the `Ownable` pattern (from `Ownable.sol`). It contains all the logic for token properties, the `buyTokens` sale mechanism, and the `withdraw` functionality.
-   **`script/AiderToken.s.sol`**: This Foundry script (`DeployAiderToken.s.sol`) is used to deploy the `AiderToken` contract to a blockchain. It handles the deployment transaction and sets the deployer as the initial owner of the contract.
-   **`test/AiderToken.t.sol`**: This file contains the Foundry tests for the `AiderToken` contract. It includes a comprehensive suite of tests covering:
    -   Initial token properties (name, symbol, decimals, owner).
    -   The `buyTokens` function:
        -   Correct token minting for exact ETH amounts.
        -   Correct token minting and ETH refund for overpayments.
        -   Rejection of transactions with zero ETH.
    -   The `withdraw` function:
        -   Successful withdrawal by the owner.
        -   Rejection of withdrawal attempts by non-owners.
        -   Rejection of withdrawal attempts when the contract balance is zero.
    -   The `receive()` ETH functionality.
    -   Fuzz testing for `buyTokens` with various valid amounts.

## Development and Usage (Foundry)

1.  **Install Dependencies**:
    Ensure OpenZeppelin Contracts v5 are installed in your Foundry project:
    ```bash
    forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit
    ```

2.  **Build Contracts**:
    Compile the smart contracts:
    ```bash
    forge build
    ```

3.  **Run Tests**:
    Execute the test suite:
    ```bash
    forge test
    ```

4.  **Deploy Contract (Example using a local Anvil node)**:
    a.  Start a local Anvil development node:
        ```bash
        anvil
        ```
    b.  In a separate terminal, deploy the `AiderToken` contract using the deployment script. Replace `YOUR_ANVIL_PRIVATE_KEY` with one of the private keys provided by Anvil:
        ```bash
        forge script script/AiderToken.s.sol:DeployAiderToken --rpc-url http://127.0.0.1:8545 --private-key YOUR_ANVIL_PRIVATE_KEY --broadcast
        ```
        Note the deployed contract address from the output.
