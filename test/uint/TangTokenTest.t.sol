// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;
import {Test,console2} from"forge-std/Test.sol";
import {TangTokenScript,TangToken} from"../../script/TangToken.s.sol";
import {TangProxyScript,TangProxy} from "../../script/TangProxy.s.sol";

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


    function testBalanceOfTang() public {
        
    }

    function testMintTokens() public {
        (bool success,)=address(proxyContract).call(abi.encodeWithSignature("mint(address,uint256,uint256)",user,1,520));
        if(success){
            (bool success,bytes memory data)=address(proxyContract).call(abi.encodeWithSignature("balanceOf(address,uint256)",user,1));
            assertEq(abi.decode(data,(uint256)),520);
        }
    }

    function testBurnTokens() public {
        testMintTokens();
        vm.prank(admin);
        (bool success,) = address(proxyContract).call(abi.encodeWithSignature("burn(address,uint256,uint256)",user,1,520));
        assertEq(success, true);
    }

    function testFailBurnTokens() public {
        vm.prank(user);
        (bool success,) = address(proxyContract).call(abi.encodeWithSignature("burn(address,uint256,uint256)",user,1,520));
        assertEq(success, true);
    }

}