// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@redstone-finance/evm-connector/contracts/data-services/AvalancheDataServiceConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DexCore is AvalancheDataServiceConsumerBase {

    ERC20 public usd;
    bytes32 public constant AVAX_SYMBOL = bytes32("AVAX");

    constructor(ERC20 usdToken) {
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
    
    function getAuthorisedSignerIndex(address signerAddress)
    public
    view
    virtual
    override
    returns (uint8)
    {
        if (signerAddress == 0x0C39486f770B26F5527BBBf942726537986Cd7eb) {
        return 0;
        } else {
        revert SignerNotAuthorised(signerAddress);
        }
    }
}