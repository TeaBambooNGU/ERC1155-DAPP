// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

struct NetWorkingChainLinkPriceFeed {
        address priceFeedETH2USD;
        address priceFeedBTC2USD;
}

contract ChainLinkConfig is Script {

    NetWorkingChainLinkPriceFeed public  activeChainlinkPriceFeed;

    

    address public constant ChainLinkSepoliaPriceFeed_ETH_USD= 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address public constant ChainLinkSepoliaPriceFeed_BTC_USD= 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43;
    uint8 public constant ETH_USD_DECIMALS = 8;
    uint8 public constant BTC_USD_DECIMALS = 8;
    int256 public constant ETH_USD_INIT_PRICE = 2000e8;
    int256 public constant BTC_USD_INIT_PRICE = 52136e8;


    constructor() {
        if (block.chainid == 11155111) {
            activeChainlinkPriceFeed = getSepoliaPriceFeed();
        }else if(block.chainid == 31337) {
            activeChainlinkPriceFeed = getAnvilPriceFeed();
        }
    }

    function getSepoliaPriceFeed() private pure returns (NetWorkingChainLinkPriceFeed memory) {

        NetWorkingChainLinkPriceFeed memory sepoliaPriceFeed = NetWorkingChainLinkPriceFeed({
            priceFeedETH2USD: ChainLinkSepoliaPriceFeed_ETH_USD,
            priceFeedBTC2USD: ChainLinkSepoliaPriceFeed_BTC_USD
        });
        return sepoliaPriceFeed;
    }

    function getAnvilPriceFeed() public  returns (NetWorkingChainLinkPriceFeed memory) {
        // 如果已经初始化了 就不用再初始化了
        if(activeChainlinkPriceFeed.priceFeedETH2USD != address(0)){
            return activeChainlinkPriceFeed;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3 = new MockV3Aggregator(ETH_USD_DECIMALS,ETH_USD_INIT_PRICE);
        address anvilPriceFeedETH2USD = address(mockV3);

        MockV3Aggregator mockV2 = new MockV3Aggregator(BTC_USD_DECIMALS,BTC_USD_INIT_PRICE);
        address anvilPriceFeedBTC2USD = address(mockV2);

        vm.stopBroadcast();

        NetWorkingChainLinkPriceFeed memory anvilPriceFeed = NetWorkingChainLinkPriceFeed({
            priceFeedETH2USD: anvilPriceFeedETH2USD,
            priceFeedBTC2USD: anvilPriceFeedBTC2USD
        });
        return anvilPriceFeed;
    }

    function getActiveChainlinkPriceFeed() public view returns (NetWorkingChainLinkPriceFeed memory) {
        return activeChainlinkPriceFeed;  
    }


}
