// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract DexClassic {

    ERC20 public usd;
    AggregatorV3Interface public priceFeed; 

    constructor(ERC20 usdToken) {
        usd = usdToken;        
        priceFeed = AggregatorV3Interface(0xe36A95a391B6889355524d3855B4f9c881fd546A);
    }

    function changeAvaxToUsd() external payable {
        uint256 usdAmount = getExpectedUsdAmount(msg.value);
        usd.transfer(msg.sender, usdAmount);
    }

    function getExpectedUsdAmount(uint256 avaxToSwap) public view returns (uint256) {
        //return avaxToSwap
        uint256 avaxPrice = getAvaxPrice();
        return avaxToSwap * avaxPrice / 10**8;
    }

    function getAvaxPrice() public view returns (uint256) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }
}