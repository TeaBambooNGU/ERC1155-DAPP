// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/TangProxy.sol";

contract TangProxyScript is Script {

    function setUp() public {}

    function run() external {
        vm.startBroadcast();
        TangProxy tangProxy = new TangProxy();
        vm.stopBroadcast();

    }

}