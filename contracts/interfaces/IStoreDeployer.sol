// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../libraries/sharedStructs.sol";

interface IStoreDeployer {
    function storeParameters()
        external
        view
        returns (address _controller, address _owner);
}
