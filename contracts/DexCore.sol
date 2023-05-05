// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@redstone-finance/evm-connector/contracts/data-services/MainDemoConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DexCore is MainDemoConsumerBase, Ownable {

    ERC20 public usd;
    bytes32 public constant AVAX_SYMBOL = bytes32("AVAX");

    constructor(ERC20 usdToken) Ownable() {
        usd = usdToken;        
    }

    function changeAvaxToUsd() external payable {
        uint256 usdAmount = getExpectedUsdAmount(msg.value);
        usd.transfer(msg.sender, usdAmount);
    }

    function getExpectedUsdAmount(uint256 avaxToSwap) public view returns (uint256) {
        uint256 avaxPrice = getAvaxPrice();
        return avaxToSwap * avaxPrice / 10**8;
    }

    function getAvaxPrice() public view returns (uint256) {
        return getOracleNumericValueFromTxMsg(AVAX_SYMBOL);
    }

    function withdrawFunds() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}