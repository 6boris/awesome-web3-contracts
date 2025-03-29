import { generatePrivateKey, privateKeyToAccount } from "viem/accounts";
import { encodeFunctionData, formatEther, getContract, TransactionRequestLegacy, createPublicClient, http } from "viem";
import BigNumber from "bignumber.js";
import ERC20AbiJson from "../../abi/ERC20Evm.json";
import BatchTransferAbiJson from "../../abi/BatchTransferEvm.json";
import { polygon as baseChain } from "viem/chains";
import type { Address } from "abitype";

const client = createPublicClient({
  chain: baseChain,
  transport: http("..."), // RPC URL
});
const managerAccount = privateKeyToAccount("0x000..."); // EVM PRIVATE KEY
const batchTransferContract = "0x000..."; // Batch Transfer Contract
export interface ToItem {
  address: Address;
  amount: BigNumber;
  memo: string;
}

async function Summary() {
  const callRes = await client.getBalance({ address: managerAccount.address });
  return {
    chain_name: client.chain.name,
    account: managerAccount.address,
    native_balance: formatEther(callRes),
  };
}

async function PrivateKey() {
  console.log(managerAccount.address);
}

export async function SendNativeTransaction(address: Address, amount: BigNumber) {
  const chainId = await client.getChainId();
  const nonce = await client.getTransactionCount({
    address: managerAccount.address,
  });
  let tx: TransactionRequestLegacy = {
    from: managerAccount.address,
    to: address,
    value: BigInt(amount.multipliedBy(1e18).toFixed(0, BigNumber.ROUND_FLOOR)),
    data: "0x",
  };
  tx.nonce = nonce;
  tx.gas = await client.estimateGas({ ...tx });
  tx.gasPrice = BigInt(
    BigNumber((await client.getGasPrice()).toString())
      .multipliedBy(1.2123)
      .toFixed(0, BigNumber.ROUND_FLOOR),
  );
  const rawSignedTx = await managerAccount.signTransaction({
    ...tx,
    chainId: chainId,
  });
  const txResp = await client.sendRawTransaction({
    serializedTransaction: rawSignedTx,
  });
  return {
    opt: "SendERC20Transaction",
    tx_hash: txResp,
    raw_tx: rawSignedTx,
  };
}

export async function SendERC20Transaction(contract: Address, address: Address, amount: BigNumber) {
  const contractInst = getContract({
    address: contract,
    abi: ERC20AbiJson,
    client: client,
  });
  const chainId = await client.getChainId();
  const decimals = Number(await contractInst.read.decimals());
  const nonce = Number(await client.getTransactionCount({ address: managerAccount.address }));
  const tmpAmount = BigInt(amount.multipliedBy(10 ** decimals).toFixed(0, BigNumber.ROUND_FLOOR));
  const abiData = encodeFunctionData({
    abi: ERC20AbiJson,
    functionName: "transfer",
    args: [privateKeyToAccount(generatePrivateKey()).address, tmpAmount],
  });
  let tx: TransactionRequestLegacy = {
    from: managerAccount.address,
    to: contract,
    value: BigInt(0),
    data: abiData,
  };
  tx.gas = await client.estimateGas({ ...tx, account: managerAccount.address });
  tx.nonce = nonce;
  tx.gasPrice = BigInt(
    BigNumber((await client.getGasPrice()).toString())
      .multipliedBy(1.2321)
      .toFixed(0, BigNumber.ROUND_FLOOR),
  );
  const rawSignedTx = await managerAccount.signTransaction({
    ...tx,
    chainId: chainId,
  });

  const txResp = await client.sendRawTransaction({
    serializedTransaction: rawSignedTx,
  });
  return {
    opt: "SendERC20Transaction",
    from: managerAccount.address,
    to: address,
    contract: contract,
    amount: amount.toFixed(18),
    tx_hash: txResp,
    raw_tx: rawSignedTx,
  };
}

export async function SendERC20ApproveTransaction(contract: Address, to: Address, amount: BigNumber) {
  const chainId = await client.getChainId();
  const nonce = Number(await client.getTransactionCount({ address: managerAccount.address }));

  let tx: TransactionRequestLegacy = {
    from: managerAccount.address,
    to: contract,
    value: BigInt(0),
    data: encodeFunctionData({
      abi: ERC20AbiJson,
      functionName: "approve",
      args: [to, `0x${amount.toString(16)}`],
    }),
    nonce: nonce,
  };
  tx.gas = (await client.estimateGas({ ...tx, account: managerAccount.address })) + BigInt(1);
  tx.gasPrice = BigInt(
    BigNumber((await client.getGasPrice()).toString())
      .multipliedBy(1.2321)
      .toFixed(0, BigNumber.ROUND_FLOOR),
  );
  const rawSignedTx = await managerAccount.signTransaction({
    ...tx,
    chainId: chainId,
  });
  const txResp = await client.sendRawTransaction({
    serializedTransaction: rawSignedTx,
  });
  return {
    opt: "SendERC20ApproveTransaction",
    contract: contract,
    from: managerAccount.address,
    to: to,
    amount: amount.toString(),
    tx_hash: txResp,
    raw_tx: rawSignedTx,
  };
}

export async function BatchSendNativeTransaction(items: ToItem[]) {
  const chainId = await client.getChainId();
  const nonce = Number(await client.getTransactionCount({ address: managerAccount.address }));
  const decimals = 18;
  let sumNativeAmount = BigInt(0);
  let toItemAmountList: bigint[] = [];
  let toItemAddressList: string[] = [];
  items.map(function (item) {
    const itemAmountWei = BigInt(item.amount.multipliedBy(10 ** decimals).toFixed(0, BigNumber.ROUND_FLOOR));
    sumNativeAmount += itemAmountWei;
    toItemAmountList.push(itemAmountWei);
    toItemAddressList.push(item.address);
  });
  const abiData = encodeFunctionData({
    abi: BatchTransferAbiJson,
    functionName: "BatchTransferNative",
    args: [toItemAddressList, toItemAmountList],
  });
  let tx: TransactionRequestLegacy = {
    from: managerAccount.address,
    to: batchTransferContract,
    value: sumNativeAmount,
    data: abiData,
    nonce: nonce,
  };
  tx.gas = (await client.estimateGas({ ...tx, account: managerAccount.address })) + BigInt(2);
  tx.gasPrice = BigInt(
    BigNumber((await client.getGasPrice()).toString())
      .multipliedBy(1.2321)
      .toFixed(0, BigNumber.ROUND_FLOOR),
  );
  const rawSignedTx = await managerAccount.signTransaction({
    ...tx,
    chainId: chainId,
  });
  const txResp = await client.sendRawTransaction({
    serializedTransaction: rawSignedTx,
  });
  return {
    opt: "BatchSendNativeTransaction",
    from: managerAccount.address,
    tx_hash: txResp,
    raw_tx: rawSignedTx,
  };
}

export async function BatchSendERC20Transaction(contract: Address, items: ToItem[]) {
  const erc20Inst = getContract({
    address: contract,
    abi: ERC20AbiJson,
    client: client,
  });
  const chainId = await client.getChainId();
  const decimals = Number(await erc20Inst.read.decimals());
  const nonce = Number(await client.getTransactionCount({ address: managerAccount.address }));
  let toItemAmountList: bigint[] = [];
  let toItemAddressList: string[] = [];
  items.map(function (item) {
    const itemAmountWei = BigInt(item.amount.multipliedBy(10 ** decimals).toFixed(0, BigNumber.ROUND_FLOOR));
    toItemAmountList.push(itemAmountWei);
    toItemAddressList.push(item.address);
  });
  let tx: TransactionRequestLegacy = {
    from: managerAccount.address,
    to: batchTransferContract,
    value: BigInt(0),
    nonce: nonce,
    data: encodeFunctionData({
      abi: BatchTransferAbiJson,
      functionName: "BatchTransferERC20",
      args: [contract, toItemAddressList, toItemAmountList],
    }),
  };
  tx.gas = (await client.estimateGas({ ...tx, account: managerAccount.address })) + BigInt(3);
  tx.gasPrice = BigInt(
    BigNumber((await client.getGasPrice()).toString())
      .multipliedBy(1.2321)
      .toFixed(0, BigNumber.ROUND_FLOOR),
  );
  const rawSignedTx = await managerAccount.signTransaction({
    ...tx,
    chainId: chainId,
  });

  const txResp = await client.sendRawTransaction({
    serializedTransaction: rawSignedTx,
  });
  return {
    opt: "BatchSendERC20Transaction",
    from: managerAccount.address,
    contract: contract,
    tx_hash: txResp,
    raw_tx: rawSignedTx,
  };
}

export async function SendTx(rawSignedTx: `0x${string}`) {
  const txResp = await client.sendRawTransaction({
    serializedTransaction: rawSignedTx,
  });
  return {
    from: managerAccount.address,
    tx_hash: txResp,
    raw_tx: rawSignedTx,
  };
}

Summary().then(console.log);

// 1. Deploy Contract On chain
/*
forge create --rpc-url $RPC_URL \
    --interactive \
    --verify \
    --broadcast \
    -e=$ETHERSCAN_KEY \
    contracts/Tool/Batch/BatchTransfer.sol:BatchTransfer
*/

// 2. Update conf in ts script

// 3.SendNativeTransaction ...
// SendNativeTransaction(privateKeyToAccount(generatePrivateKey()).address, BigNumber("0.000000000123")).then((res) => {
//   console.log(res);
// });

// 4.SendERC20Transaction ...
// SendERC20Transaction(
//   "0xc2132D05D31c914a87C6611C10748AEb04B58e8F", // USDT in Polygon POS
//   privateKeyToAccount(generatePrivateKey()).address,
//   BigNumber("0.00000123"),
// ).then(console.log);

// 5.BatchSendNativeTransaction ...
// BatchSendNativeTransaction([
//   {address: privateKeyToAccount(generatePrivateKey()).address, amount: BigNumber("0.0000000001"), memo: ""},
//   {address: privateKeyToAccount(generatePrivateKey()).address, amount: BigNumber("0.0000000002"), memo: ""},
//   {address: privateKeyToAccount(generatePrivateKey()).address, amount: BigNumber("0.0000000003"), memo: ""},
// ]).then(console.log);

// 6.SendERC20ApproveTransaction ...
// SendERC20ApproveTransaction(
//   "0xc2132D05D31c914a87C6611C10748AEb04B58e8F",
//   batchTransferContract,
//   BigNumber(10 ** 6),
// ).then(console.log);

// 7.BatchSendERC20Transaction ...
// BatchSendERC20Transaction(
//   '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
//   [
//     {address: privateKeyToAccount(generatePrivateKey()).address, amount: BigNumber("0.000001"), memo: ""},
//     {address: privateKeyToAccount(generatePrivateKey()).address, amount: BigNumber("0.000002"), memo: ""},
//     {address: privateKeyToAccount(generatePrivateKey()).address, amount: BigNumber("0.000003"), memo: ""},
//     {address: privateKeyToAccount(generatePrivateKey()).address, amount: BigNumber("0.000004"), memo: ""},
//     {address: privateKeyToAccount(generatePrivateKey()).address, amount: BigNumber("0.000006"), memo: ""},
//   ]
// ).then(console.log)
