// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {TangToken} from "../src/TangToken.sol";
import {ChainLinkConfig,NetWorkingChainLinkVRF} from "./ChainLinkConfig.s.sol";

contract TangTokenScript is Script {
    address private admin = makeAddr("admin");
    NetWorkingChainLinkVRF private chainLinkVRF;

    modifier init() {
        ChainLinkConfig chainlinkConfig = new ChainLinkConfig();
        chainLinkVRF = chainlinkConfig.getActiveChainlinkVRF();
        _;
    }


    function setUp() public {
    }

    function run() external init returns (TangToken){
        vm.startBroadcast();
        // ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 无聊猿的IPFS地址
        TangToken tangToken = new TangToken(
            "TANG", 
            "TANG1155", 
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            chainLinkVRF.vrfCoordinator,
            chainLinkVRF.numWords
            );
        vm.stopBroadcast();
        return tangToken;
    }

    function runByTest() external init returns (TangToken) {
        vm.startBroadcast(admin);
        // ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 无聊猿的IPFS地址
        TangToken tangToken = new TangToken(
            "TANG", 
            "TANG1155", 
            "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/",
            chainLinkVRF.vrfCoordinator,
            chainLinkVRF.numWords
            );
        vm.stopBroadcast();
        return tangToken;
    }
}
