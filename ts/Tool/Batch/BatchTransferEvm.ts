import { Web3, utils, Address } from "web3";
import BigNumber from "bignumber.js";

const client = new Web3("https://eth.llamarpc.com");

async function GetNativeBalance(address: Address) {
  const calResp = await client.eth.getBalance(address);
  return new BigNumber(utils.fromWei(calResp, "wei")).div(1e18).toString();
}
async function GetERC20Balance(address: Address) {
  const calResp = await client.eth.getBalance(address);
  return new BigNumber(utils.fromWei(calResp, "wei")).div(1e18).toString();
}

GetNativeBalance("0xafca650fdaa8b6611c9cd71202cf010d33e4e999").then(console.log);
