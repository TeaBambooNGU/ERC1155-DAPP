// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TangProxy} from "../src/TangProxy.sol";
import {ChainLinkConfig, NetWorkingChainLinkPriceFeed, NetWorkingChainLinkVRF} from "./ChainLinkConfig.s.sol";
import {ChainLinkEnum} from "../src/ChainLinkEnum.sol";

contract TangProxyScript is Script {

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

    // modifier init() {
    //     chainlinkConfig = new ChainLinkConfig();
    //     NetWorkingChainLinkPriceFeed memory feedStruct = chainlinkConfig.getActiveChainlinkPriceFeed();
    //     chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.ETH_USD)] = feedStruct.priceFeedETH2USD;
    //     chainLinkDataFeeds[uint256(ChainLinkEnum.dataFeedType.BTC_USD)] = feedStruct.priceFeedBTC2USD;
    //     chainLinkVRF = chainlinkConfig.getActiveChainlinkVRF();
    //     _;
    // }

    function run(
        uint256 deployKey,
        address logicAddress,
        bytes memory _data,
        string memory _uri,
        string memory _wish,
        address[] memory _chainLinkDataFeeds,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint16 _requestConfirmations,
        uint32 _callbackGasLimit,
        uint32 _numWords
        ) external returns (TangProxy) {
        
        vm.startBroadcast(deployKey);
        TangProxy tangProxy = new TangProxy(
            logicAddress,
            _data,
            _wish,
            _uri,
            _chainLinkDataFeeds,
            _vrfCoordinator,
            _keyHash,
            _subscriptionId,
            _requestConfirmations,
            _callbackGasLimit,
            _numWords
        );
        vm.stopBroadcast();
        return tangProxy;
    }

}
