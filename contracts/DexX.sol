// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@redstone-finance/evm-connector/contracts/data-services/MainDemoConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DexX is MainDemoConsumerBase, Ownable {

    bytes32 public constant AVAX_SYMBOL = bytes32("AVAX");
    uint256 public constant REQUEST_TTL_IN_BLOCKS = 3;

    // We don't need params for the swap requests
    // because all of them can be extracted from the transaction data
    event NewSwapRequest();

    ERC20 public usd;
    mapping (bytes32 => bool) requestedSwaps;

    constructor(ERC20 usdToken) Ownable() {
        usd = usdToken;        
    }

    // This function is called by a user to request a swap
    // It doesn't require attaching a redstone payload
    function changeAvaxToUsd() external payable {
        bytes32 requestHash = calculateHashForSwapRequest(msg.value, msg.sender, block.number);
        requestedSwaps[requestHash] = true;
        emit NewSwapRequest();
    }

    // This function is called by a kepper and triggered by the NewSwapRequest event
    // It requires attaching a specific redstone payload
    function executeSwap(
        uint256 avaxToSwap,
        address requestedBy,
        uint256 requestedAtBlock
    ) external payable {
        // Check if the request actually exists
        bytes32 requestHash = calculateHashForSwapRequest(avaxToSwap, requestedBy, requestedAtBlock);
        require(requestedSwaps[requestHash], "Can not find swap request with the given params");
        delete requestedSwaps[requestHash];

        // We need to check if the attached data are equal to the block number of the request tx
        // We keep the block numbers instead of timestamp in redstone payload for the model X
        uint256 dataPackagesBlockNumber = extractTimestampsAndAssertAllAreEqual();
        require(dataPackagesBlockNumber == requestedAtBlock, "Block number mismatch in payload and request");

        // Transfer USD back to user
        uint256 avaxPrice = getOracleNumericValueFromTxMsg(AVAX_SYMBOL);
        uint256 usdAmount = avaxToSwap * avaxPrice / 10**8;
        usd.transfer(msg.sender, usdAmount);
    }

    function calculateHashForSwapRequest(
        uint256 avaxToSwap,
        address requestedBy,
        uint256 requestedAtBlock
    ) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(avaxToSwap, requestedBy, requestedAtBlock));
    }

    // The name of this function can be a bit misleading here, but it returns
    // the block number, because oracle nodes that are used in the model X
    // Put block numbers instead of timestamps to the signed oracle data
    function validateTimestamp(uint256 receivedBlockNumber) public view virtual override {
        require(block.number > receivedBlockNumber, "Data block number is too new");
        require(block.number - receivedBlockNumber > REQUEST_TTL_IN_BLOCKS, "Swap request expired");
    }

    function withdrawFunds() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // The functions below can not be implemented in the model X
    // Because the user doesn't know the price price before requesting the swap
    // function getExpectedUsdAmount(uint256 avaxToSwap) public view returns (uint256) {}
    // function getAvaxPrice() public view returns (uint256) {}
}
