// SPDX-License-Identifier: MIT
pragma solidity 0.8;
contract MyContract{

    event ReceiveEvent(address sender,uint amount);
    event FallbackEvent(address sender,uint amount,bytes data);
    fallback() external payable { 

        emit FallbackEvent(msg.sender,msg.value,msg.data);
    }


    receive() external payable {
        emit ReceiveEvent(msg.sender,msg.value);
     }
}


contract GetSig{
    function getSig()public pure returns(bytes4){
        return msg.sig;
    }

    function getContractBalance()public view returns(uint){
        return address(this).balance;
    }
}