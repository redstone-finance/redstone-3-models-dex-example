// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DexClassic is Ownable {

    ERC20 public usd;
    AggregatorV3Interface public priceFeed; 

    constructor(ERC20 usdToken) Ownable() {
        // You should replace address(0) with your deployed PriceFeed address
        priceFeed = AggregatorV3Interface(address(0));
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
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function withdrawFunds() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}