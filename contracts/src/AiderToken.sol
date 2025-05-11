// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract AiderToken is ERC20, Ownable {
    uint256 public constant TOKEN_PRICE = 0.1 ether; // 1 AID = 0.1 ETH

    constructor(address initialOwner) ERC20("AIDER", "AID") Ownable(initialOwner) {
        // Decimals are 18 by default in OpenZeppelin's ERC20.sol
    }

    function buyTokens() public payable {
        require(msg.value > 0, "AiderToken: ETH amount must be greater than 0");

        uint256 tokensToMint = (msg.value * (10**decimals())) / TOKEN_PRICE;
        require(tokensToMint > 0, "AiderToken: Not enough ETH to buy any tokens");

        _mint(msg.sender, tokensToMint);

        uint256 cost = tokensToMint * TOKEN_PRICE / (10**decimals());
        uint256 refundAmount = msg.value - cost;

        if (refundAmount > 0) {
            (bool success, ) = msg.sender.call{value: refundAmount}("");
            require(success, "AiderToken: Refund failed");
        }
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "AiderToken: No ETH to withdraw");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "AiderToken: Withdrawal failed");
    }

    // Allow contract to receive ETH directly
    receive() external payable {}
}
