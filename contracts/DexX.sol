// contracts/DexX.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@redstone-finance/evm-connector/contracts/data-services/MainDemoConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DexX is MainDemoConsumerBase, Ownable {

    bytes32 public constant AVAX_SYMBOL = bytes32("AVAX");

    event NewOracleDataRequest(
        uint256 indexed avaxToSwap,
        address indexed requestedBy,
        uint256 indexed requestedAtBlock
    );

    ERC20 public usd;
    mapping (bytes32 => bool) requestedSwaps;

    constructor(ERC20 usdToken) Ownable() {
        usd = usdToken;        
    }

    // This function is called by a user to request a swap
    // It doesn't require attaching a redstone payload
    function changeAvaxToUsd() external payable {
        bytes32 requestHash = calculateHashForSwapRequest(msg.value, msg.sender, block.number);
        require(!requestedSwaps[requestHash], "Request with the same params already exists");
        requestedSwaps[requestHash] = true;
        emit NewOracleDataRequest(msg.value, msg.sender, block.number);
    }

    // This function is called by a keeper and triggered by the NewOracleDataRequest event
    // It requires attaching a specific redstone payload
    function executeWithOracleData(
        uint256 avaxToSwap,
        address requestedBy,
        uint256 requestedAtBlock
    ) external payable {
        // Check if the request actually exists
        bytes32 requestHash = calculateHashForSwapRequest(avaxToSwap, requestedBy, requestedAtBlock);
        require(requestedSwaps[requestHash], "Can not find swap request with the given params");
        delete requestedSwaps[requestHash];

        // We need to check if the block number of the attached data is equal to the block number of
        // the request tx. We use block numbers instead of timestamp in redstone payload for the model X
        uint256 dataPackagesBlockNumber = extractTimestampsAndAssertAllAreEqual();
        require(dataPackagesBlockNumber == requestedAtBlock, "Block number mismatch in payload and request");

        // Transfer USD to the swap requester
        uint256 usdAmount = getExpectedUsdAmount(avaxToSwap);
        usd.transfer(requestedBy, usdAmount);
    }

    function calculateHashForSwapRequest(
        uint256 avaxToSwap,
        address requestedBy,
        uint256 requestedAtBlock
    ) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(avaxToSwap, requestedBy, requestedAtBlock));
    }

    // Despite the name, this function returns the block number from
    // the attached redstone payload in the model X
    function validateTimestamp(uint256 _receivedBlockNumber) public view virtual override {
        // It's empty, because we disable block number validation in this function, since
        // we already validate the oracle data block number in the `executeWithOracleData` function
    }

    // This function requires an attached redstone payload
    // It is used by keepers, but can also be used by DEX users
    // to estimate an approximate USD amount they can receive for the given avax amount
    function getExpectedUsdAmount(uint256 avaxToSwap) public view returns (uint256) {
        uint256 avaxPrice = getAvaxPrice();
        return avaxToSwap * avaxPrice / 10**8;
    }

    // This function requires an attached redstone payload
    // It is used by keepers, but can also be used by DEX users
    // to estimate an approximate price of AVAX for their trades
    function getAvaxPrice() public view returns (uint256) {
        return getOracleNumericValueFromTxMsg(AVAX_SYMBOL);
    }

    function withdrawFunds() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
