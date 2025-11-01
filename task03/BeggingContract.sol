// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
contract BeggingContract{

    mapping (address donor => uint256 amount) private beggingMap;

    uint256 private totalDonations;

   
    function donate()public payable {
        beggingMap[msg.sender]+=msg.value;
        totalDonations+=msg.value;
    }
    
    function withdraw(address payable _address)public {
        require(msg.sender==_address,"Not the owner");
        uint256  amount = totalDonations;
        totalDonations = 0;
        payable(_address).transfer(amount);
    }

    function getDonation(address _donor)public view returns(uint256){
        return beggingMap[_donor];
    }

}