// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../interfaces/BEP20.sol";
import "./mlx.sol";

contract MLXPOS is BEP20("Metple POS", "MLXPOS", 18) {
    METAPLE private mlx;

    constructor(METAPLE _mlx) {
        mlx = _mlx;
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from ,uint256 _amount) external onlyOwner {
        _burn(_from, _amount);
    }

    function safeMLXTransfer(address _to, uint256 _amount) external onlyOwner {
        uint256 mlxBal = mlx.balanceOf(address(this));
        if (_amount > mlxBal) {
            mlx.transfer(_to, mlxBal);
        } else {
            mlx.transfer(_to, _amount);
        }
    }
}