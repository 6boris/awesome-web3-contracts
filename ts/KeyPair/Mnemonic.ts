import * as bip39 from "@scure/bip39";
import { wordlist } from "@scure/bip39/wordlists/english";
import { utils, eth } from "web3";
import { createPublicClient, http } from "viem";
import { mainnet } from "viem/chains";
// https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
// https://viem.sh/docs/getting-started

const client = createPublicClient({
  chain: mainnet,
  transport: http(),
});

export async function GenerateMnemonic() {
  const mn = bip39.generateMnemonic(wordlist, 128);
  return mn;
}

export async function GenerateEvmPrivateKey() {
  const transaction = await client.getTransaction({
    hash: "0xa991c3803a8124ef1329edc6fce7608a7bbf08ae5a6302da9d94bbd737858d7e",
  });

  // 3. Consume an action!
  const blockNumber = await client.getBlockNumber();
  return blockNumber;
}

// GenerateMnemonic().then(console.log);
GenerateEvmPrivateKey().then(console.log);
