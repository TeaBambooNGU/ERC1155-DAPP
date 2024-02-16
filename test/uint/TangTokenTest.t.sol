// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;
import {Test,console2} from"forge-std/Test.sol";
import {TangTokenScript,TangToken} from"../../script/TangToken.s.sol";
import {TangProxyScript,TangProxy} from "../../script/TangProxy.s.sol";

contract TangTokenTest is Test {

    TangProxy public proxyContract;
    address private i_user;
    
    function setUp() public {

        TangTokenScript tangtokenScript = new TangTokenScript();
        TangToken tangtoken = tangtokenScript.run();

        TangProxyScript tangProxyScript = new TangProxyScript(); 
        proxyContract = tangProxyScript.runByLogic(address(tangtoken));
        i_user = makeAddr("receiver");
        
    }


    function testBalanceOfTang() public {
        
    }

    function testMintTokens() public {
        (bool success,)=address(proxyContract).call(abi.encodeWithSignature("mint(address,uint256,uint256)",i_user,1,520));
        if(success){
            (bool success,bytes memory data)=address(proxyContract).call(abi.encodeWithSignature("balanceOf(address,uint256)",i_user,1));
            assertEq(abi.decode(data,(uint256)),520);
        }
    }

}