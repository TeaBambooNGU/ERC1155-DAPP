// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {

    NetWorkingChainLinkPriceFeed public  chainlinkPriceFeed;

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
            priceFeedETHUSD: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaPriceFeed;
    }

    function getChainLinkPriceFeed() public view returns (NetWorkingChainLinkPriceFeed memory) {
        return chainlinkPriceFeed;  
    }
}
