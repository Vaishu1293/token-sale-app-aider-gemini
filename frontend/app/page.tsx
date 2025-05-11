'use client';

import { useState } from 'react';
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { formatEther, parseEther } from 'viem';

const contractAddress = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'; // replace this

const abi = [
  {
    name: 'buyTokens',
    type: 'function',
    stateMutability: 'payable',
    inputs: [],
    outputs: [],
  },
];

export default function Home() {
  const { isConnected } = useAccount();
  const [hash, setHash] = useState<`0x${string}` | null>(null);
  const [error, setError] = useState<any>(null);

  const {
    data: txHash,
    writeContract,
    isPending,
  } = useWriteContract();

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const handleBuy = () => {
    setError(null);
    try {
      writeContract({
        address: contractAddress,
        abi,
        functionName: 'buyTokens',
        value: parseEther('0.1'),
      });
    } catch (err) {
      setError(err);
    }
  };

  // capture hash when tx is sent
  if (txHash && txHash !== hash) {
    setHash(txHash);
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-black to-gray-900 text-white flex flex-col items-center justify-center p-6 space-y-8">
      <h1 className="text-4xl font-bold">AIDER Token Sale</h1>
      <p>Price: <strong>0.1 ETH</strong> per AID token</p>

      <ConnectButton />

      {isConnected && (
        <Button onClick={handleBuy} disabled={isPending || isConfirming}>
          {isPending ? 'Confirming in wallet...' : isConfirming ? 'Waiting for confirmation...' : 'Buy 1 AID Token'}
        </Button>
      )}

      {!isConnected && <Alert>Connect your wallet to buy AID tokens.</Alert>}

      {hash && <Alert>Transaction Hash: {hash}</Alert>}
      {isSuccess && <Alert>✅ Transaction confirmed! You received 1 AID token.</Alert>}
      {error && <Alert variant="destructive">❌ {error?.shortMessage || error.message}</Alert>}

      <footer className="mt-10 text-sm text-gray-400">
        Powered by Next.js, RainbowKit, Wagmi, Tailwind, Viem
      </footer>
    </div>
  );
}
