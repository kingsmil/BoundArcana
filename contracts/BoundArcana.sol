// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BoundArcana is ERC721URIStorage{
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    //this method is not that secure apparently
    function random() private view returns(uint){
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender)));
    }
    mapping(uint256 => StatBlock) public tokenIdToStats;
    struct StatBlock { 
      uint256 Level;
      uint256 Speed;
      uint256 Strength;
      uint256 Life;
   }
    constructor() ERC721("BoundArcana", "ACNA") {}
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )internal virtual override(ERC721){
        require((from==address(0)|| to ==address(0)),"mint transfers only");
        super._beforeTokenTransfer(from,to,tokenId);
    }
    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToStats[tokenId].Level;
        return levels.toString();
    }
    function getSpeed(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToStats[tokenId].Speed;
        return levels.toString();
    }
    function getStrength(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToStats[tokenId].Strength;
        return levels.toString();
    }
    function getLife(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToStats[tokenId].Life;
        return levels.toString();
    }
    function mint() public {
        _tokenIdCounter.increment();
        uint256 newItemId = _tokenIdCounter.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToStats[newItemId].Level = 0;
        tokenIdToStats[newItemId].Speed = random()%20+10;
        tokenIdToStats[newItemId].Strength = random()%20+10;
        tokenIdToStats[newItemId].Life = random()%90+10;
        _setTokenURI(newItemId, getTokenURI(newItemId));
}
    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Arcana Battles #', tokenId.toString(), '",',
                '"description": "Arcana on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
    function generateCharacter(uint256 tokenId) public view returns(string memory){
        
    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"The Tower",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
        '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getSpeed(tokenId),'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getStrength(tokenId),'</text>',
        '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",getLife(tokenId),'</text>',
        '</svg>'
    );
    return string(
        abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
        )    
    );
    }
 function train(uint256 tokenId) public {
   require(_exists(tokenId));
   require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");
   uint256 currentLevel = tokenIdToStats[tokenId].Level;
   tokenIdToStats[tokenId].Level = currentLevel + 1;
   _setTokenURI(tokenId, getTokenURI(tokenId));
}
}