pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Hello} from "contracts/Hello.sol";

contract HelloTest is Test {
    Hello hello;

    function setUp() public {
        hello = new Hello();
    }

    function testHello() public {
        hello.hello();
    }
}
