// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TangProxy} from "../src/TangProxy.sol";
import {ChainLinkConfig, NetWorkingChainLinkPriceFeed, NetWorkingChainLinkVRF} from "./ChainLinkConfig.s.sol";
import {ChainLinkEnum} from "../src/ChainLinkEnum.sol";

contract TangProxyScript is Script {
    address private admin = makeAddr("admin");

    string private constant wish = "Wish Tang Wan always happy, healthy, and everything goes well";

    /**
     * @notice chainlink dataFeed 货币交易对价格
     * 数组中的地址顺序为ChainLinkEnum枚举顺序 对应不同的token交易对
     * see src/ChainLinkEnum.sol
     * 0: ETH / USD
     * 1: BTC / USD
     */
    address[] public chainLinkDataFeeds = new address[](2);

    NetWorkingChainLinkVRF private chainLinkVRF;
    ChainLinkConfig private chainlinkConfig;

    modifier init() {
        admin = makeAddr("admin");
        chainlinkConfig = new ChainLinkConfig();
        NetWorkingChainLinkPriceFeed memory feedStruct = chainlinkConfig.getActiveChainlinkPriceFeed();
        chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.ETH_USD)] = feedStruct.priceFeedETH2USD;
        chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.BTC_USD)] = feedStruct.priceFeedBTC2USD;
        chainLinkVRF = chainlinkConfig.getActiveChainlinkVRF();
        _;
    }

    function setUp() public {}

    function run() external init returns (TangProxy) {
        vm.startBroadcast();
        address tangLogic = 0xdBC7563dEC14a25801a3D199a21Bde084ae269AC;
        TangProxy tangProxy = new TangProxy(
            tangLogic,
            "",
            wish,
            chainLinkDataFeeds,
            chainLinkVRF.vrfCoordinator,
            chainLinkVRF.keyHash,
            chainLinkVRF.subscriptionId,
            chainLinkVRF.requestConfirmations,
            chainLinkVRF.callbackGasLimit,
            chainLinkVRF.numWords
        );
        vm.stopBroadcast();
        return tangProxy;
    }

    function runByLogic(address logicAddress) external init returns (TangProxy) {
        vm.startBroadcast(admin);
        TangProxy tangProxy = new TangProxy(
            logicAddress,
            "",
            wish,
            chainLinkDataFeeds,
            chainLinkVRF.vrfCoordinator,
            chainLinkVRF.keyHash,
            chainLinkVRF.subscriptionId,
            chainLinkVRF.requestConfirmations,
            chainLinkVRF.callbackGasLimit,
            chainLinkVRF.numWords
        );
        vm.stopBroadcast();
        // 添加VRF消费者
        chainlinkConfig.addConsumer(address(tangProxy));
        
        return tangProxy;
    }
}
