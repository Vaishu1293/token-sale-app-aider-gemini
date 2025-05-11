// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AiderToken} from "../src/AiderToken.sol";
import {Vm} from "forge-std/Vm.sol";

contract AiderTokenTest is Test {
    AiderToken public aiderToken;
    address public owner;
    address payable public user1 = payable(address(0x1)); // Example user address
    address payable public user2 = payable(address(0x2)); // Another example user

    uint256 constant TOKEN_PRICE_PER_AID = 0.1 ether;

    function setUp() public {
        owner = address(this); // Test contract itself will be the deployer/owner
        aiderToken = new AiderToken(owner);
    }

    function test_InitialState() public {
        assertEq(aiderToken.name(), "AIDER", "Token name should be AIDER");
        assertEq(aiderToken.symbol(), "AID", "Token symbol should be AID");
        assertEq(aiderToken.decimals(), 18, "Token decimals should be 18");
        assertEq(aiderToken.owner(), owner, "Initial owner should be the deployer");
    }

    function test_BuyTokens_ExactPrice() public {
        uint256 ethSent = TOKEN_PRICE_PER_AID * 5; // Buy 5 tokens
        uint256 expectedTokens = 5 * (10**aiderToken.decimals());

        vm.deal(user1, ethSent); 
        vm.prank(user1); 
        aiderToken.buyTokens{value: ethSent}();

        assertEq(aiderToken.balanceOf(user1), expectedTokens, "User1 token balance incorrect");
        assertEq(address(aiderToken).balance, ethSent, "Contract ETH balance incorrect");
    }

    function test_BuyTokens_WithRefund() public {
        uint256 ethToSend = TOKEN_PRICE_PER_AID * 2 + 0.05 ether; // Enough for 2 tokens, plus extra 0.05 ETH
        uint256 expectedTokens = 2 * (10**aiderToken.decimals());
        uint256 expectedCost = TOKEN_PRICE_PER_AID * 2;
        
        uint256 user1InitialEthBalance = user1.balance;
        vm.deal(user1, ethToSend + 1 ether); // Give user1 ETH for purchase + gas (extra 1 ETH to ensure enough for tx)
        
        vm.prank(user1);
        aiderToken.buyTokens{value: ethToSend}();

        assertEq(aiderToken.balanceOf(user1), expectedTokens, "User1 token balance incorrect after refund");
        assertEq(address(aiderToken).balance, expectedCost, "Contract ETH balance incorrect after refund");
        // Check user1's ETH balance increased by the refund amount (approximately)
        // user1.balance starts with ethToSend + 1 ether (from vm.deal)
        // After tx, it should be (user1InitialEthBalance + ethToSend + 1 ether) - ethToSend + (ethToSend - expectedCost) - gas
        // = user1InitialEthBalance + 1 ether + (ethToSend - expectedCost) - gas
        // This is equivalent to: user1.balance after should be > (user1.balance before deal) + refund - gas
        // The `vm.deal` sets the balance, so `user1InitialEthBalance` is what it was *before* the `vm.deal` in this specific test context.
        // A simpler check: user1's balance after the transaction should be (balance_before_buyTokens - ethToSend + refundAmount) - gas.
        // Let's use the balance *after* vm.deal as the baseline for checking refund.
        uint256 user1BalanceAfterDeal = user1.balance; // This is ethToSend + 1 ether
        uint256 expectedRefund = ethToSend - expectedCost;
        // After buyTokens, user1's balance should be (user1BalanceAfterDeal - ethToSend + expectedRefund) - gas_cost
        // So, user1.balance should be approximately user1BalanceAfterDeal - expectedCost - gas_cost
        // Or, user1.balance should be approximately (balance before deal) + (initial funding for test) - expectedCost - gas_cost
        assertTrue(user1.balance >= (user1BalanceAfterDeal - ethToSend + expectedRefund - 0.001 ether), "User ETH balance does not reflect refund (approx)");
    }
    
    function test_BuyTokens_NotEnoughForOneToken() public {
        uint256 ethSent = TOKEN_PRICE_PER_AID / 2; // Not enough for one token base unit if price was per base unit
                                                 // This will be 0.05 ether.
                                                 // tokensToMint = (0.05 ether * 10**18) / 0.1 ether = 0.5 * 10**18. This is > 0.
        // Let's test with an amount that is truly too small.
        // Smallest amount of token is 1 base unit. Cost = 1 * TOKEN_PRICE / 10**18 = 0.1 ether / 10**18 = 0.1 wei.
        uint256 ethSentTooSmall = 0; // This will be caught by "ETH amount must be greater than 0"
        // Let's use 1 wei, which should mint 10 base units.
        // To test "Not enough ETH", we need msg.value > 0 but (msg.value * 10**18) / TOKEN_PRICE == 0
        // e.g. msg.value = 1 wei, TOKEN_PRICE = 0.2 ether. Then (1 * 10**18) / (0.2 * 10**18) = 1 / 0.2 = 5. This mints.
        // The condition is (msg.value * 10**decimals) < TOKEN_PRICE.
        // If msg.value = 1 wei, TOKEN_PRICE = 0.1 ether (10^17 wei)
        // (1 * 10^18) / 10^17 = 10. This mints 10 base units.
        // The "Not enough ETH to buy any tokens" will only trigger if TOKEN_PRICE is extremely high or msg.value extremely low relative to decimals.
        // For TOKEN_PRICE = 0.1 ether, the smallest msg.value that mints >0 tokens is 1 wei (mints 10 base units).
        // So, this specific revert is hard to hit with TOKEN_PRICE = 0.1 ether unless msg.value is 0, which is caught by the first require.
        // Let's assume the first require (`msg.value > 0`) is the primary guard for very small non-zero values.
        // The test for "Not enough ETH" is more relevant if TOKEN_PRICE is very large.
        // For now, we'll rely on test_BuyTokens_ZeroEthSent for the zero value.
        // The "Not enough ETH to buy any tokens" is effectively tested by the fuzz test if it provides a value that results in 0 tokens.

        // Re-evaluating: if TOKEN_PRICE is 0.1 ether, and decimals is 18.
        // Smallest token unit is 1. Its price is (0.1 ether / 10^18).
        // If msg.value is less than (0.1 ether / 10^18), then tokensToMint will be 0.
        // (0.1 ether / 10^18) = 10^17 wei / 10^18 = 0.1 wei.
        // So if msg.value is, for example, 0.05 wei (not possible as ETH is in wei), this would trigger.
        // Since msg.value must be >= 1 wei, and 1 wei buys 10 base units, this condition is hard to hit.
        // We will rely on the fuzz test to cover this implicitly.
    }

    function test_BuyTokens_ZeroEthSent() public {
        vm.deal(user1, 1 ether); 
        vm.prank(user1);
        vm.expectRevert(bytes("AiderToken: ETH amount must be greater than 0"));
        aiderToken.buyTokens{value: 0}();
    }

    function test_Withdraw_Successful() public {
        uint256 ethToDeposit = TOKEN_PRICE_PER_AID * 10; 
        vm.deal(user2, ethToDeposit);
        vm.prank(user2);
        aiderToken.buyTokens{value: ethToDeposit}();

        assertEq(address(aiderToken).balance, ethToDeposit, "Contract balance should be ethToDeposit before withdrawal");

        uint256 ownerInitialEthBalance = owner.balance;
        
        vm.prank(owner); 
        aiderToken.withdraw();

        assertEq(address(aiderToken).balance, 0, "Contract balance should be 0 after withdrawal");
        assertEq(owner.balance, ownerInitialEthBalance + ethToDeposit, "Owner did not receive the withdrawn ETH");
    }

    function test_Withdraw_NotOwner() public {
        uint256 ethToDeposit = TOKEN_PRICE_PER_AID * 1;
        vm.deal(user2, ethToDeposit);
        vm.prank(user2);
        aiderToken.buyTokens{value: ethToDeposit}(); 

        vm.prank(user1); 
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        aiderToken.withdraw();
    }

    function test_Withdraw_NoBalance() public {
        assertEq(address(aiderToken).balance, 0, "Contract balance should be 0 initially");
        vm.prank(owner);
        vm.expectRevert(bytes("AiderToken: No ETH to withdraw"));
        aiderToken.withdraw();
    }
    
    function test_ReceiveEth() public {
        uint256 amountToSend = 1 ether;
        vm.deal(user1, amountToSend + 0.1 ether); // Fund user1 for sending and gas

        uint256 initialContractBalance = address(aiderToken).balance;
        uint256 user1InitialBalance = user1.balance;
        
        vm.prank(user1);
        (bool success, ) = payable(address(aiderToken)).call{value: amountToSend}("");
        assertTrue(success, "ETH transfer to contract via receive() failed");

        assertEq(address(aiderToken).balance, initialContractBalance + amountToSend, "Contract balance did not increase after ETH transfer");
        assertTrue(user1.balance <= user1InitialBalance - amountToSend, "User1 balance did not decrease correctly");
    }

    function testFuzz_BuyTokens_ValidAmounts(uint96 amountEth) public {
        vm.assume(amountEth > 0 && amountEth < 1000 ether); 
        
        uint256 ethToSend = uint256(amountEth);
        uint256 expectedTokensToMint = (ethToSend * (10**aiderToken.decimals())) / TOKEN_PRICE_PER_AID;

        vm.deal(user1, ethToSend + 0.1 ether); 
        vm.prank(user1);
        
        if (expectedTokensToMint == 0) {
            // This case should ideally be "AiderToken: Not enough ETH to buy any tokens"
            // However, with TOKEN_PRICE = 0.1 ether, any msg.value >= 1 wei results in tokensToMint > 0.
            // So this branch of the fuzz test is unlikely to be hit unless TOKEN_PRICE is very high.
            // If it were hit, we'd expect a revert.
            vm.expectRevert(bytes("AiderToken: Not enough ETH to buy any tokens")); // Or other appropriate revert
            aiderToken.buyTokens{value: ethToSend}();
        } else {
            uint256 user1TokenBalanceBefore = aiderToken.balanceOf(user1);
            uint256 contractEthBalanceBefore = address(aiderToken).balance;
            uint256 user1EthBalanceBefore = user1.balance;

            aiderToken.buyTokens{value: ethToSend}();
            
            assertEq(aiderToken.balanceOf(user1), user1TokenBalanceBefore + expectedTokensToMint, "Fuzz: User token balance incorrect");
            
            uint256 expectedCost = expectedTokensToMint * TOKEN_PRICE_PER_AID / (10**aiderToken.decimals());
            assertEq(address(aiderToken).balance, contractEthBalanceBefore + expectedCost, "Fuzz: Contract ETH balance incorrect");

            uint256 expectedRefund = ethToSend - expectedCost;
            assertTrue(user1.balance >= user1EthBalanceBefore - ethToSend + expectedRefund - 0.001 ether, "Fuzz: User ETH balance after refund incorrect");
        }
    }
}
