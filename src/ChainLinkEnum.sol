// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

/**
 * @notice chainlink dataFeed 货币交易对价格
 * 数组中的地址顺序为特定顺序 对应不同的token交易对
 * 日后扩展按顺序添加，并在注释中注明
 * 0: ETH / USD
 * 1: BTC / USD
 */
library ChainLinkEnum {
    enum dataFeedType {
        ETH_USD,
        BTC_USD
    }
}
