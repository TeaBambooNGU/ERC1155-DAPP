// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract ChainLinkConfig is Script {

    NetWorkingChainLinkPriceFeed public  activeChainlinkPriceFeed;

    

    address public constant ChainLinkSepoliaPriceFeed_ETH_USD= 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    uint8 public constant ETH_USD_DECIMALS = 8;
    int256 public constant ETH_USD_INIT_PRICE = 2000e8;

    struct NetWorkingChainLinkPriceFeed {
        address priceFeedETHUSD;
    }
    constructor() {
        if (block.chainid == 11155111) {
            activeChainlinkPriceFeed = getSepoliaPriceFeed();
        }else if(block.chainid == 31337) {
            activeChainlinkPriceFeed = getAnvilPriceFeed();
        }
    }

    function getSepoliaPriceFeed() private pure returns (NetWorkingChainLinkPriceFeed memory) {

        NetWorkingChainLinkPriceFeed memory sepoliaPriceFeed = NetWorkingChainLinkPriceFeed({
            priceFeedETHUSD: ChainLinkSepoliaPriceFeed_ETH_USD});
        return sepoliaPriceFeed;
    }

    function getAnvilPriceFeed() public  returns (NetWorkingChainLinkPriceFeed memory) {
        // 如果已经初始化了 就不用再初始化了
        if(activeChainlinkPriceFeed.priceFeedETHUSD != address(0)){
            return activeChainlinkPriceFeed;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3 = new MockV3Aggregator(ETH_USD_DECIMALS,ETH_USD_INIT_PRICE);
        address anvilPriceFeedETHUSD = address(mockV3);
        vm.stopBroadcast();

        NetWorkingChainLinkPriceFeed memory anvilPriceFeed = NetWorkingChainLinkPriceFeed({
            priceFeedETHUSD: anvilPriceFeedETHUSD});
        return anvilPriceFeed;
    }

    function getChainLinkPriceFeed() public view returns (NetWorkingChainLinkPriceFeed memory) {
        return activeChainlinkPriceFeed;  
    }


}
