// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DataFeedConsumerV3 {

    AggregatorV3Interface public immutable chainlinkFeed;


    constructor(address chainlinkFeedAddress) {
        chainlinkFeed = AggregatorV3Interface(
            chainlinkFeedAddress
        );
    }

    /**
     * 返回chainlink上 eth和usd交易对的最新交易价格
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = chainlinkFeed.latestRoundData();
        return answer;
    }

    function getVersion() public view returns (uint256) {
        return chainlinkFeed.version();
    }


}