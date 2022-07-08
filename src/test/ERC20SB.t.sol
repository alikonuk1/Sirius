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

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockERC20SB} from "./utils/mocks/MockERC20SB.sol";

contract ERC20SBTest is DSTestPlus {
    MockERC20SB token;

    bytes32 constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    function setUp() public {
        token = new MockERC20SB("SBToken", "SBTKN", 18);
    }

    function invariantMetadata() public {
        assertEq(token.name(), "SBToken");
        assertEq(token.symbol(), "SBTKN");
        assertEq(token.decimals(), 18);
    }

    function testMint() public {
        token.mint(address(0xBEEF), 1e18);

        assertEq(token.totalSupply(), 1e18);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testBurn() public {
        token.mint(address(0xBEEF), 1e18);
        token.burn(address(0xBEEF), 0.9e18);

        assertEq(token.totalSupply(), 1e18 - 0.9e18);
        assertEq(token.balanceOf(address(0xBEEF)), 0.1e18);
    }

    function testFailApprove() public {
        assertTrue(token.approve());
    }

    function testFailTransfer() public {
        token.mint(address(this), 1e18);

        assertTrue(token.transfer());
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.balanceOf(address(this)), 1e18);
    }

    function testFailTransferFrom() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        hevm.prank(from);
        token.approve();

        assertTrue(token.transferFrom());
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.balanceOf(from), 1e18);
    }

    function testMetadata(
        string calldata name,
        string calldata symbol,
        uint8 decimals
    ) public {
        MockERC20SB tkn = new MockERC20SB(name, symbol, decimals);
        assertEq(tkn.name(), name);
        assertEq(tkn.symbol(), symbol);
        assertEq(tkn.decimals(), decimals);
    }

    function testMint(address from, uint256 amount) public {
        token.mint(from, amount);

        assertEq(token.totalSupply(), amount);
        assertEq(token.balanceOf(from), amount);
    }

    function testBurn(
        address from,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        burnAmount = bound(burnAmount, 0, mintAmount);

        token.mint(from, mintAmount);
        token.burn(from, burnAmount);

        assertEq(token.totalSupply(), mintAmount - burnAmount);
        assertEq(token.balanceOf(from), mintAmount - burnAmount);
    }

    function testFailBurnInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        burnAmount = bound(burnAmount, mintAmount + 1, type(uint256).max);

        token.mint(to, mintAmount);
        token.burn(to, burnAmount);
    }
}