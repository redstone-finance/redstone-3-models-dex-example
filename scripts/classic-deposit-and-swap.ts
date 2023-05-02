import {ethers, deployments, getNamedAccounts, getUnnamedAccounts} from 'hardhat';

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
  const swapTx = await Dex.changeAvaxToUsd({value: ethers.utils.parseEther("1")});    
  const swapReceipt = await swapTx.wait();

  console.log("Gas used: " + swapReceipt.gasUsed.toString());

  const dexUsdBalanceAfterSwap = await Usd.balanceOf(Dex.address);
  console.log("Dex usd balance after swap: " + ethers.utils.formatEther(dexUsdBalanceAfterSwap));

}


  (async () => {
    const Usd = await ethers.getContract("Usd");
    const Dex = await ethers.getContract("DexClassic");

    await depositUsdToDex(Usd, Dex, "100");
    await swapAVAXToUsd(Usd, Dex, "1");
    
  })();