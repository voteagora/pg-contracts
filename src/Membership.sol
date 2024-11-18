// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable-v5/token/ERC721/ERC721Upgradeable.sol";
import {ERC721BurnableUpgradeable} from
    "@openzeppelin/contracts-upgradeable-v5/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable-v5/access/AccessControlUpgradeable.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable-v5/utils/cryptography/EIP712Upgradeable.sol";
import {ERC721VotesUpgradeable} from
    "@openzeppelin/contracts-upgradeable-v5/token/ERC721/extensions/ERC721VotesUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable-v5/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable-v5/proxy/utils/UUPSUpgradeable.sol";

contract Membership is
    Initializable,
    ERC721Upgradeable,
    ERC721BurnableUpgradeable,
    AccessControlUpgradeable,
    EIP712Upgradeable,
    ERC721VotesUpgradeable,
    UUPSUpgradeable
{
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error NotTransferable();

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 private _nextTokenId;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        _disableInitializers();
    }

    /*//////////////////////////////////////////////////////////////
                             PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function initialize(address defaultAdmin) public initializer {
        __ERC721_init("Protocol Guild Membership", "GUILD");
        __ERC721Burnable_init();
        __AccessControl_init();
        __EIP712_init("Protocol Guild Membership", "1");
        __ERC721Votes_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, defaultAdmin);
        _grantRole(UPGRADER_ROLE, defaultAdmin);
        _grantRole(BURNER_ROLE, defaultAdmin);
    }

    function mint(address[] calldata recipients) public onlyRole(MINTER_ROLE) {
        uint256 startTokenId = _nextTokenId;
        uint256 numRecipients = recipients.length;

        for (uint256 i = 0; i < numRecipients; i++) {
            _safeMint(recipients[i], startTokenId + i);
        }

        _nextTokenId = startTokenId + numRecipients;
    }

    function burn(uint256 tokenId) public override onlyRole(BURNER_ROLE) {
        _update(address(0), tokenId, _msgSender());
    }

    function burn(uint256[] calldata tokenIds) public {
        uint256 numTokens = tokenIds.length;
        for (uint256 i = 0; i < numTokens; i++) {
            burn(tokenIds[i]);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721Upgradeable, ERC721VotesUpgradeable)
        returns (address)
    {
        if (_ownerOf(tokenId) != address(0) && to != address(0)) revert NotTransferable();
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721Upgradeable, ERC721VotesUpgradeable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}
}
