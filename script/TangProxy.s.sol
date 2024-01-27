// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/TangProxy.sol";

contract TangProxyScript is Script {

    function setUp() public {}

    function run() external {
        vm.startBroadcast();
        address tangLogic = 0xdBC7563dEC14a25801a3D199a21Bde084ae269AC;
        string memory wish = "Wish Tang Wan always happy, healthy, and everything goes well";
        TangProxy tangProxy = new TangProxy(tangLogic,"",wish);
        vm.stopBroadcast();

    }

}