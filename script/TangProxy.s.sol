// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TangProxy} from "../src/TangProxy.sol";

contract TangProxyScript is Script {

    string private constant wish = "Wish Tang Wan always happy, healthy, and everything goes well";

    function setUp() public {}

    function run() external returns (TangProxy){
        vm.startBroadcast();
        address tangLogic = 0xdBC7563dEC14a25801a3D199a21Bde084ae269AC;
        TangProxy tangProxy = new TangProxy(tangLogic,"",wish);
        vm.stopBroadcast();
        return tangProxy;
    }

    function runByLogic(address logicAddress) external returns (TangProxy) {
        vm.startBroadcast();
        TangProxy tangProxy = new TangProxy(logicAddress,"",wish);
        vm.stopBroadcast();
        return tangProxy;
    }

}