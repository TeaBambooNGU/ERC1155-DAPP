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

    function run(
        uint256 deployKey,
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _vrfCoordinator,
        uint32 _numWords
        ) external init returns (TangToken){
            
        vm.startBroadcast(deployKey);
        // ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 无聊猿的IPFS地址
        TangToken tangToken = new TangToken(
            _name,
            _symbol,
            _uri,
            _vrfCoordinator,
            _numWords);
        vm.stopBroadcast();
        return tangToken;
    }

}
