// SPDX-License-Identifier: MIT
pragma solidity 0.8;

contract Test{

    receive() external payable { }  

    fallback() external payable { }


    event CallLog(bytes input,bytes output);
    function withdrawWithTransfer() external{
        payable(msg.sender).transfer(1 ether);
    }


    function withdrawWithSend() external{
        bool success =  payable(msg.sender).send(1 ether);
        require(success);
    }


    function withdrawWithCall(bytes calldata input)external {
        (bool success,) =  payable(msg.sender).call{value:1 ether}(input);
        require(success,"Call failed");
    }


    function getContractBalance()public view returns(uint256){
        return address(this).balance;
    }
}

contract TestUser{

    Test _test;

    constructor(address payable addr){
        _test = Test(addr);
    }
    function withdrawWithTransfer() external{
        _test.withdrawWithTransfer();
    }


    function withdrawWithSend() external{
       _test.withdrawWithSend();
    }


    function withdrawWithCall(bytes calldata input)external {
        _test.withdrawWithCall(input);
    }


    function testPay() public payable returns(string memory){
        return "success";
    }


    receive() external payable { }

}