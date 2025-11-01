// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//导包
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract MyNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 private _tokenId = 1;

    constructor() ERC721("QNFT", "QNFT") Ownable(msg.sender) {}
    
    function mintNFT(address _to, string memory _uri) public onlyOwner {
        require(_to != address(0), "Invalid recipient");
        uint256 newTokenId = _tokenId++;
        _safeMint(_to, newTokenId);
        _setTokenURI(newTokenId, _uri);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
