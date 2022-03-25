//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../helpers/Ownable.sol";
import "../../interfaces/BEP20.sol";
import "./dtpl.sol";

contract TTPLDPoS is Ownable, BEP20("TESTPLE Deposit Proof of Stake", "TTPLDPoS", 18) {
    event MetapleTokenDeployed (address metapleTokenAddress);

    bool private isDeployed;
    TTPLDP private mtpldp;

    constructor (TTPLDP _mtpldp) {
        mtpldp = _mtpldp;
        isDeployed = true;
        assert(isDeployed == true);
        emit MetapleTokenDeployed(address(this));
    }

    function mtpldpTransfer(address _to,uint256 _amount) external onlyOwner {
        uint256 _mtplDpBal = mtpldp.balanceOf(address(this));
        
        // Check available MTPL DP for transfer
        if(_mtplDpBal < _amount) {
            mtpldp.transfer(_to, _mtplDpBal);
        }else{
            mtpldp.transfer(_to, _amount);
        }
    }
}