// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    NetWorkingChainLinkPriceFeed public  chainlinkPriceFeed;

    address public constant ChainLinkSepoliaPriceFeed_ETH_USD= 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    uint8 public constant ETH_USD_DECIMALS = 8;
    int256 public constant ETH_USD_INITANSWER = 2000e18;

    struct NetWorkingChainLinkPriceFeed {
        address priceFeedETHUSD;
    }
    constructor() {
        if (block.chainid == 11155111) {
            chainlinkPriceFeed = getSepoliaPriceFeed();
        }
    }

    function getSepoliaPriceFeed() private pure returns (NetWorkingChainLinkPriceFeed memory) {

        NetWorkingChainLinkPriceFeed memory sepoliaPriceFeed = NetWorkingChainLinkPriceFeed({
            priceFeedETHUSD: ChainLinkSepoliaPriceFeed_ETH_USD});
        return sepoliaPriceFeed;
    }

    function getAnvilPriceFeed() public  returns (NetWorkingChainLinkPriceFeed memory) {
        vm.startBroadcast();
        MockV3Aggregator mockV3 = new MockV3Aggregator(ETH_USD_DECIMALS,ETH_USD_INITANSWER);
        address anvilPriceFeedETHUSD = address(mockV3);
        vm.stopBroadcast();
        NetWorkingChainLinkPriceFeed memory anvilPriceFeed = NetWorkingChainLinkPriceFeed({
            priceFeedETHUSD: anvilPriceFeedETHUSD});
        return anvilPriceFeed;
    }

    function getChainLinkPriceFeed() public view returns (NetWorkingChainLinkPriceFeed memory) {
        return chainlinkPriceFeed;  
    }
}
