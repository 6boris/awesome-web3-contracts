import dayjs from "dayjs";
import { utils, eth } from "web3";
const tNow = dayjs();
console.log(tNow.format("YYYY-MM-DDTHH:mm:ssZ[Z]"));

console.log(
  utils.keccak256(
    eth.abi.encodeParameter("uint256[]", [
      "11397568185806560130291530949248708355673262872727946990834312389557386886033",
      "54405834204020870944342294544757609285398723182661749830189277079337680158706",
      "27",
    ]),
  ),
);

console.log(
  utils.toNumber(
    "115_792_089_237_316_195_423_570_985_008_687_907_852_837_564_279_074_904_382_605_163_141_518_161_494_337",
  ),
);
