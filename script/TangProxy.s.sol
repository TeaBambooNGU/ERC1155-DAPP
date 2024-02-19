// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TangProxy} from "../src/TangProxy.sol";

contract TangProxyScript is Script {
    address private admin = makeAddr("admin");

    string private constant wish = "Wish Tang Wan always happy, healthy, and everything goes well";

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
        admin = makeAddr("admin");
        chainLinkDataFeeds[0] = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        chainLinkDataFeeds[1] = 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43;
    }

    function run() external returns (TangProxy) {
        vm.startBroadcast();
        address tangLogic = 0xdBC7563dEC14a25801a3D199a21Bde084ae269AC;
        TangProxy tangProxy = new TangProxy(tangLogic, "", wish,chainLinkDataFeeds);
        vm.stopBroadcast();
        return tangProxy;
    }

    function runByLogic(address logicAddress) external returns (TangProxy) {
        chainLinkDataFeeds[0] = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        chainLinkDataFeeds[1] = 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43;
        vm.startBroadcast(admin);
        TangProxy tangProxy = new TangProxy(logicAddress, "", wish,chainLinkDataFeeds);
        vm.stopBroadcast();
        return tangProxy;
    }
}
