pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Hello} from "contracts/Hello.sol";

contract HelloTest is Test {
    Hello hello;

    function setUp() public {
        hello = new Hello();
    }

    /*    function testHello() public {
        hello.hello();
        assertEqDecimal(address(this).balance, 100, 3, 'ops?');
    }
*/

    function testDeposit() public {
        Test.deal(address(this), 1 ether);
        console.log(address(this).balance);
        assertEqDecimal(address(this).balance, 1000000000000000000, 1, "ops?");

        assert(0 < hello.deposit{value: 0.08 ether}());
    }
}
