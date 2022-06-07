// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IStoreDeployer {
    function storeParameters()
        external
        view
        returns (
            address factory,
            address owner,
            address token,
            uint8 storeIndex
        );
}
