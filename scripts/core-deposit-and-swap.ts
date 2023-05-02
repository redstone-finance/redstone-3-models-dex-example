import {ethers, deployments, getNamedAccounts, getUnnamedAccounts} from 'hardhat';
import { WrapperBuilder } from "@redstone-finance/evm-connector";

async function depositUsdToDex(Usd, Dex, amountOfUsd) {
  const dexUsdBalanceBefore = await Usd.balanceOf(Dex.address);
  console.log("Dex usd balance before deposit: " + ethers.utils.formatEther(dexUsdBalanceBefore));
  
  const depositTx = await Usd.transfer(Dex.address, ethers.utils.parseEther(amountOfUsd));    
  const depositReceipt = await depositTx.wait();

  console.log("Executing deposit tx: " + depositReceipt.transactionHash);

  const dexUsdBalance = await Usd.balanceOf(Dex.address);
  console.log("Dex usd balance after deposit: " + ethers.utils.formatEther(dexUsdBalance));
}

async function swapAVAXToUsd(Usd, Dex, amountOfAvax) {
  const WrappedDex = WrapperBuilder.wrap(Dex).usingDataService(
    {
      dataServiceId: "redstone-main-demo",
      uniqueSignersCount: 1,
      dataFeeds: ["AVAX"],
    },
    ["https://d33trozg86ya9x.cloudfront.net"]
  );


  const swapTx = await WrappedDex.changeAvaxToUsd({value: ethers.utils.parseEther(amountOfAvax)});    
  const swapReceipt = await swapTx.wait();
  console.log("Executing swap tx: " + swapReceipt.transactionHash);
  console.log("Gas used: " + swapReceipt.gasUsed.toString());

  const dexUsdBalanceAfterSwap = await Usd.balanceOf(Dex.address);
  console.log("Dex usd balance after swap: " + ethers.utils.formatEther(dexUsdBalanceAfterSwap));

}


  (async () => {
    const Usd = await ethers.getContract("Usd");
    const Dex = await ethers.getContract("DexCore");

    await depositUsdToDex(Usd, Dex, "100");
    await swapAVAXToUsd(Usd, Dex, "1");
    
  })();