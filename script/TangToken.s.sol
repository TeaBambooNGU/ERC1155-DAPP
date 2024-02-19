// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {TangToken} from "../src/TangToken.sol";

contract TangTokenScript is Script {
    address private admin = makeAddr("admin");
    /**
     * @notice chainlink dataFeed 货币交易对价格
     * 数组中的地址顺序为特定顺序 对应不同的token交易对
     * 日后扩展按顺序添加，并在注释中注明
     * see src/ChainLinkEnum.sol
     * 0: ETH / USD
     * 1: BTC / USD
     */
    address[] public chainLinkDataFeeds = new address[](2);

    function setUp() public {
    }

    function run() external returns (TangToken) {
        vm.startBroadcast();
        // ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 无聊猿的IPFS地址
        TangToken tangToken = new TangToken(
            "TANG", "TANG1155", "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/");
        vm.stopBroadcast();
        return tangToken;
    }

    function runByTest() external returns (TangToken) {
        vm.startBroadcast(admin);
        // ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 无聊猿的IPFS地址
        TangToken tangToken = new TangToken(
            "TANG", "TANG1155", "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/");
        vm.stopBroadcast();
        return tangToken;
    }
}
