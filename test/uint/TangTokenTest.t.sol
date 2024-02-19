// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ChainLinkEnum} from "../../src/ChainLinkEnum.sol";
import {TangTokenScript, TangToken} from "../../script/TangToken.s.sol";
import {TangProxyScript, TangProxy} from "../../script/TangProxy.s.sol";
contract TangTokenTest is Test {
    TangProxy public proxyContract;
    address private user;
    address private admin;

    function setUp() public {
        admin = makeAddr("admin");
        user = makeAddr("receiver");
        // 先部署逻辑合约
        TangTokenScript tangtokenScript = new TangTokenScript();
        TangToken tangtoken = tangtokenScript.runByTest();
        // 再部署代理合约
        TangProxyScript tangProxyScript = new TangProxyScript();
        proxyContract = tangProxyScript.runByLogic(address(tangtoken));
    }

    function testBalanceOfTang() public {}

    function testMintTokens() public {
        (bool success,) =
            address(proxyContract).call(abi.encodeWithSignature("mint(address,uint256,uint256)", user, 1, 520));
        if (success) {
            (, bytes memory data) =
                address(proxyContract).call(abi.encodeWithSignature("balanceOf(address,uint256)", user, 1));
            assertEq(abi.decode(data, (uint256)), 520);
        }
    }

    function testBurnTokens() public {
        testMintTokens();
        vm.prank(admin);
        (bool success,) =
            address(proxyContract).call(abi.encodeWithSignature("burn(address,uint256,uint256)", user, 1, 520));
        assertEq(success, true);
    }

    function testFailBurnTokens() public {
        vm.prank(user);
        (bool success,) =
            address(proxyContract).call(abi.encodeWithSignature("burn(address,uint256,uint256)", user, 1, 520));
        assertEq(success, true);
    }

    function testEnumSort() public {
        assertEqUint(uint256(ChainLinkEnum.dataFeedType.ETH_USD), 0);
        assertEqUint(uint256(ChainLinkEnum.dataFeedType.BTC_USD), 1);
    }

    function testGetETH2USD() public {
        (bool success, bytes memory data) =
            address(proxyContract).call(abi.encodeWithSignature("getETH2USDLatestAnswer()"));
        
        if (success) {
            console2.log(abi.decode(data, (int256)));
            
        }
        assertEq(success, true);
    }

    function testGetETH2USDVersion() public {
        (bool success, bytes memory data) =
            address(proxyContract).call(abi.encodeWithSignature("getETH2USDVersion()"));
        if (success) {
            console2.log(abi.decode(data, (uint256)));
        }
         assertEq(success, true);
    
    }
}
