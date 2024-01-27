// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;
import "forge-std/Script.sol";
import "../src/TangToken.sol";

contract TangTokenScript is Script {

    function setUp() public {
        
    }

    function run() external {
        vm.startBroadcast();
        // ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 无聊猿的IPFS地址
        TangToken tangToken = new TangToken("TANG","TANG1155","ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/");
        vm.stopBroadcast();
    }

}