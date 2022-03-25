//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../helpers/Ownable.sol";
import "../../interfaces/BEP20.sol";
import "../bsc/mlx.sol";

contract TTPLDP is Ownable, BEP20("METAPLE Deposit Proof", "TTPLDP", 18) {
    event MetapleTokenDeployed (address metapleTokenAddress);

    bool private isDeployed;
    METAPLE private mtpl;

    constructor (METAPLE _mtpl) {
        mtpl = _mtpl;
        isDeployed = true;
        assert(isDeployed == true);
        emit MetapleTokenDeployed(address(this));
    }

    function mtplTransfer(address _to,uint256 _amount) external onlyOwner {
        uint256 _mtplBal = mtpl.balanceOf(address(this));
        
        // Check available MTPL for transfer
        if(_mtplBal < _amount) {
            mtpl.transfer(_to, _mtplBal);
        }else{
            mtpl.transfer(_to, _amount);
        }
    }
}