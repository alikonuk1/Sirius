// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC1155SB} from "../../../src/tokens/soulbound/ERC1155SB.sol";

contract MockERC1155SB is ERC1155SB {
    function uri(uint256) public pure virtual override returns (string memory) {}

    function mint(address to, uint256 id, uint256 amount, bytes memory data) public virtual {
        _mint(to, id, amount, data);
    }

    function batchMint(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual {
        _batchMint(to, ids, amounts, data);
    }

    function burn(address from, uint256 id, uint256 amount) public virtual {
        _burn(from, id, amount);
    }

    function batchBurn(address from, uint256[] memory ids, uint256[] memory amounts) public virtual {
        _batchBurn(from, ids, amounts);
    }
}
