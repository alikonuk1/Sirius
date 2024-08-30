/*
     ________  ___  ________  ___  ___  ___  ________      
    |\   ____\|\  \|\   __  \|\  \|\  \|\  \|\   ____\     
    \ \  \___|\ \  \ \  \|\  \ \  \ \  \\\  \ \  \___|_    
     \ \_____  \ \  \ \   _  _\ \  \ \  \\\  \ \_____  \   
      \|____|\  \ \  \ \  \\  \\ \  \ \  \\\  \|____|\  \  
        ____\_\  \ \__\ \__\\ _\\ \__\ \_______\____\_\  \ 
       |\_________\|__|\|__|\|__|\|__|\|_______|\_________\
       \|_________|                            \|_________|
                                                           
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC721SB} from "./utils/mocks/MockERC721SB.sol";

import {ERC721TokenReceiver} from "../tokens/soulbound/ERC721SB.sol";

contract ERC721Recipient is ERC721TokenReceiver {
    address public operator;
    address public from;
    uint256 public id;
    bytes public data;

    function onERC721Received(address _operator, address _from, uint256 _id, bytes calldata _data)
        public
        virtual
        override
        returns (bytes4)
    {
        operator = _operator;
        from = _from;
        id = _id;
        data = _data;

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

contract RevertingERC721Recipient is ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
        revert(string(abi.encodePacked(ERC721TokenReceiver.onERC721Received.selector)));
    }
}

contract WrongReturnDataERC721Recipient is ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
        return 0xCAFEBEEF;
    }
}

contract NonERC721Recipient {}

contract ERC721SBTest is DSTestPlus {
    MockERC721SB token;

    function setUp() public {
        token = new MockERC721SB("SBToken", "SBTKN");
    }

    function invariantMetadata() public {
        assertEq(token.name(), "SBToken");
        assertEq(token.symbol(), "SBTKN");
    }

    function testMint() public {
        token.mint(address(0xBEEF), 1337);

        assertEq(token.balanceOf(address(0xBEEF)), 1);
        assertEq(token.ownerOf(1337), address(0xBEEF));
    }

    function testBurn() public {
        token.mint(address(0xBEEF), 1337);
        token.burn(1337);

        assertEq(token.balanceOf(address(0xBEEF)), 0);

        hevm.expectRevert("NOT_MINTED");
        token.ownerOf(1337);
    }

    function testFailApproveBurn() public {
        token.mint(address(this), 1337);

        token.approve();

        token.burn(1337);

        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.getApproved(1337), address(0));

        hevm.expectRevert("NOT_MINTED");
        token.ownerOf(1337);
    }

    function testSafeMintToEOA() public {
        token.safeMint(address(0xBEEF), 1337);

        assertEq(token.ownerOf(1337), address(address(0xBEEF)));
        assertEq(token.balanceOf(address(address(0xBEEF))), 1);
    }

    function testSafeMintToERC721Recipient() public {
        ERC721Recipient to = new ERC721Recipient();

        token.safeMint(address(to), 1337);

        assertEq(token.ownerOf(1337), address(to));
        assertEq(token.balanceOf(address(to)), 1);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), address(0));
        assertEq(to.id(), 1337);
        assertBytesEq(to.data(), "");
    }

    function testSafeMintToERC721RecipientWithData() public {
        ERC721Recipient to = new ERC721Recipient();

        token.safeMint(address(to), 1337, "testing 123");

        assertEq(token.ownerOf(1337), address(to));
        assertEq(token.balanceOf(address(to)), 1);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), address(0));
        assertEq(to.id(), 1337);
        assertBytesEq(to.data(), "testing 123");
    }

    function testFailMintToZero() public {
        token.mint(address(0), 1337);
    }

    function testFailDoubleMint() public {
        token.mint(address(0xBEEF), 1337);
        token.mint(address(0xBEEF), 1337);
    }

    function testFailBurnUnMinted() public {
        token.burn(1337);
    }

    function testFailDoubleBurn() public {
        token.mint(address(0xBEEF), 1337);

        token.burn(1337);
        token.burn(1337);
    }

    function testFailSafeMintToNonERC721Recipient() public {
        token.safeMint(address(new NonERC721Recipient()), 1337);
    }

    function testFailSafeMintToNonERC721RecipientWithData() public {
        token.safeMint(address(new NonERC721Recipient()), 1337, "testing 123");
    }

    function testFailSafeMintToRevertingERC721Recipient() public {
        token.safeMint(address(new RevertingERC721Recipient()), 1337);
    }

    function testFailSafeMintToRevertingERC721RecipientWithData() public {
        token.safeMint(address(new RevertingERC721Recipient()), 1337, "testing 123");
    }

    function testFailSafeMintToERC721RecipientWithWrongReturnData() public {
        token.safeMint(address(new WrongReturnDataERC721Recipient()), 1337);
    }

    function testFailSafeMintToERC721RecipientWithWrongReturnDataWithData() public {
        token.safeMint(address(new WrongReturnDataERC721Recipient()), 1337, "testing 123");
    }

    function testFailBalanceOfZeroAddress() public view {
        token.balanceOf(address(0));
    }

    function testFailOwnerOfUnminted() public view {
        token.ownerOf(1337);
    }

    function testMetadata(string memory name, string memory symbol) public {
        MockERC721SB tkn = new MockERC721SB(name, symbol);

        assertEq(tkn.name(), name);
        assertEq(tkn.symbol(), symbol);
    }

    function testMint(address to, uint256 id) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(to, id);

        assertEq(token.balanceOf(to), 1);
        assertEq(token.ownerOf(id), to);
    }

    function testBurn(address to, uint256 id) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(to, id);
        token.burn(id);

        assertEq(token.balanceOf(to), 0);

        hevm.expectRevert("NOT_MINTED");
        token.ownerOf(id);
    }

    function testFailBurn(uint256 id) public {
        token.mint(address(this), id);

        token.approve();

        token.burn(id);

        assertEq(token.balanceOf(address(this)), 0);

        hevm.expectRevert("NOT_MINTED");
        token.ownerOf(id);
    }

    function testSafeMintToEOA(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        if (uint256(uint160(to)) <= 18 || to.code.length > 0) return;

        token.safeMint(to, id);

        assertEq(token.ownerOf(id), address(to));
        assertEq(token.balanceOf(address(to)), 1);
    }

    function testSafeMintToERC721Recipient(uint256 id) public {
        ERC721Recipient to = new ERC721Recipient();

        token.safeMint(address(to), id);

        assertEq(token.ownerOf(id), address(to));
        assertEq(token.balanceOf(address(to)), 1);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), address(0));
        assertEq(to.id(), id);
        assertBytesEq(to.data(), "");
    }

    function testSafeMintToERC721RecipientWithData(uint256 id, bytes calldata data) public {
        ERC721Recipient to = new ERC721Recipient();

        token.safeMint(address(to), id, data);

        assertEq(token.ownerOf(id), address(to));
        assertEq(token.balanceOf(address(to)), 1);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), address(0));
        assertEq(to.id(), id);
        assertBytesEq(to.data(), data);
    }

    function testFailMintToZero(uint256 id) public {
        token.mint(address(0), id);
    }

    function testFailDoubleMint(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(to, id);
        token.mint(to, id);
    }

    function testFailBurnUnMinted(uint256 id) public {
        token.burn(id);
    }

    function testFailDoubleBurn(uint256 id, address to) public {
        if (to == address(0)) to = address(0xBEEF);

        token.mint(to, id);

        token.burn(id);
        token.burn(id);
    }

    function testFailSafeMintToNonERC721Recipient(uint256 id) public {
        token.safeMint(address(new NonERC721Recipient()), id);
    }

    function testFailSafeMintToNonERC721RecipientWithData(uint256 id, bytes calldata data) public {
        token.safeMint(address(new NonERC721Recipient()), id, data);
    }

    function testFailSafeMintToRevertingERC721Recipient(uint256 id) public {
        token.safeMint(address(new RevertingERC721Recipient()), id);
    }

    function testFailSafeMintToRevertingERC721RecipientWithData(uint256 id, bytes calldata data) public {
        token.safeMint(address(new RevertingERC721Recipient()), id, data);
    }

    function testFailSafeMintToERC721RecipientWithWrongReturnData(uint256 id) public {
        token.safeMint(address(new WrongReturnDataERC721Recipient()), id);
    }

    function testFailSafeMintToERC721RecipientWithWrongReturnDataWithData(uint256 id, bytes calldata data) public {
        token.safeMint(address(new WrongReturnDataERC721Recipient()), id, data);
    }

    function testFailOwnerOfUnminted(uint256 id) public view {
        token.ownerOf(id);
    }
}
