// 
// 360Code: 248a-193a-48s8-ia24-19ma
// 
// ░█▀▄▀█ ░█▀▀▀ ▀▀█▀▀ ─█▀▀█ ░█▀▀█ ░█─── ░█▀▀▀ 
// ░█░█░█ ░█▀▀▀ ─░█── ░█▄▄█ ░█▄▄█ ░█─── ░█▀▀▀ 
// ░█──░█ ░█▄▄▄ ─░█── ░█─░█ ░█─── ░█▄▄█ ░█▄▄▄
// 
// Website: https://metaple.finance
// Telegram: https://t.me/MetapleFinance
// GitHub: https://github.com/MetapleFinance
// 
// Backed by Team Crypto360 (thecrypto360.com)
// Telegram: https://t.me/TheCrypto_360
// 

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../../interfaces/BEP20.sol";
import "../../utils/Utils360.sol";
import "../core/Ref360.sol";

contract METAPLE is BEP20("Metaple", "MLX", 18), Utils360, Ref360 {
    event MetapleDeployed (address metapleAddress);

    bool private isDeployed;
    uint256 private distribution = 150_000_000 ether;
    uint256 private distributed = 0;

    constructor () {
        isDeployed = true;
        assert(isDeployed == true);
        emit MetapleDeployed(address(this));
    }

    function initialMint() external onlyOwner {
        require(distributed < distribution, append("+ Not Enough ", getSymbol(), " Tokens To Mint"));
        _initialMint(distribution);
        distributed += distribution;
    }

    function initReferral(address _referrer) external {
        _setReferrer(msg.sender, _referrer);
    }
}