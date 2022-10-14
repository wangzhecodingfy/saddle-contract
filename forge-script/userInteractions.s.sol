// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

import "./ScriptWithConstants.s.sol";
import "../contracts/interfaces/IMasterRegistry.sol";

// TODO: script stack is so deep use --via-ir to bypass

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IMiniChefV2{
    struct UserInfo {
            uint256 amount;
            int256 rewardDebt;
        }
    // mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    function userInfo(uint pid, address user) external view returns (UserInfo memory);
    
}

interface IGaugeController{
    function n_gauges() external view returns (int128);
    function gauges(uint256) external view returns (address);
}

interface IPoolRegistry {
    /* Structs */

    struct PoolInputData {
        address poolAddress;
        uint8 typeOfAsset;
        bytes32 poolName;
        address targetAddress;
        address metaSwapDepositAddress;
        bool isSaddleApproved;
        bool isRemoved;
        bool isGuarded;
    }

    struct PoolData {
        address poolAddress;
        address lpToken;
        uint8 typeOfAsset;
        bytes32 poolName;
        address targetAddress;
        address[] tokens;
        address[] underlyingTokens;
        address basePoolAddress;
        address metaSwapDepositAddress;
        bool isSaddleApproved;
        bool isRemoved;
        bool isGuarded;
    }

    struct SwapStorageData {
        uint256 initialA;
        uint256 futureA;
        uint256 initialATime;
        uint256 futureATime;
        uint256 swapFee;
        uint256 adminFee;
        address lpToken;
    }

    struct UserInfo {
            uint256 amount;
            int256 rewardDebt;
    }

    /* Functions */

    function getPoolData(address poolAddress)
        external
        view
        returns (PoolData memory);

    function getPoolDataAtIndex(uint256 index)
        external
        view
        returns (PoolData memory);

    function getPoolDataByName(bytes32 poolName)
        external
        view
        returns (PoolData memory);

    function getVirtualPrice(address poolAddress)
        external
        view
        returns (uint256);

    function getA(address poolAddress) external view returns (uint256);

    function getPaused(address poolAddress) external view returns (bool);

    function getTokens(address poolAddress)
        external
        view
        returns (address[] memory);

    function getUnderlyingTokens(address poolAddress)
        external
        view
        returns (address[] memory);

    function getPoolsLength() external view returns (uint256);

    function getTokenBalances(address poolAddress)
        external
        view
        returns (uint256[] memory balances);

    function getUnderlyingTokenBalances(address poolAddress)
        external
        view
        returns (uint256[] memory balances);
}

contract UserInterationScript is ScriptWithConstants {
    function setUp() public override {
        super.setUp();
    }
    struct UserInfo {
            uint256 amount;
            int256 rewardDebt;
        }

    function printPools(address user) public {
        // Find MasterRegistry
        address masterRegistry = getDeploymentAddress("MasterRegistry");
        
        require(masterRegistry != address(0), "No master registry found");
        console.log("MasterRegistry address: %s", masterRegistry);

        // Find PoolRegistry
        address poolRegistry = IMasterRegistry(masterRegistry)
            .resolveNameToLatestAddress("PoolRegistry");
        console.log("PoolRegistry address: %s", poolRegistry);
        require(poolRegistry != address(0), "No pool registry found");

        IMasterRegistry mr = IMasterRegistry(masterRegistry);
        IPoolRegistry pr = IPoolRegistry(poolRegistry);

        console.log(
            "PoolRegistry on %s (%s): %s\n",
            getNetworkName(),
            block.chainid,
            address(pr)
        );

        uint256 numOfPools = pr.getPoolsLength();
        console.log("Number of pools %s", numOfPools);

        // For every pool, print tokens in array format
        for (uint256 i = 0; i < numOfPools; i++) {
            // Find the pool data at index i
            IPoolRegistry.PoolData memory poolData = pr.getPoolDataAtIndex(i);
            console.log(
                "index %s: %s",
                i,
                string(abi.encodePacked(poolData.poolName))
            );
            console.log(
                "lp token: %s",
                poolData.lpToken
            );
            // userInfo
            console.log(
                "token balance: %s",
                IERC20(poolData.lpToken).balanceOf(user)
            );
            // log minichef rewards only on networks with minichef
            if (block.chainid == 42161 || block.chainid == 10|| block.chainid == 9001) {
                address minichefV2 = getDeploymentAddress("MiniChefV2");
                IMiniChefV2 mc = IMiniChefV2(minichefV2);
                IMiniChefV2.UserInfo memory usersInfo = mc.userInfo(i, user);
                console.log(
                        "userInfo: %s",
                        i,
                        usersInfo.amount
                );
                
            }

            // log gauge rewards / veSDL locked if on mainnet
            if (block.chainid == 1){
                // get info on all LiquidityGaugeV5s
                address gaugeController = getDeploymentAddress("GaugeController");
                IGaugeController gc = IGaugeController(gaugeController);
                int256 numberOfGauges = int256(gc.n_gauges());
                console.log("Number of Gauges ");
                // TODO: can't seem to console.log the number with the text
                console.logInt(numberOfGauges);
                for (int128 j = 0; j < numberOfGauges-1; j++){
                    address gauge = gc.gauges(j);
                    console.log("Gauge address: %s", gauge);
                    console.log("Gauge balance: %s", IERC20(gauge).balanceOf(user));
                }
            }
        }
    }

    function run() public {
        // https://github.com/foundry-rs/forge-std/blob/master/src/Vm.sol
        vm.startBroadcast();
        address user = 0xffD2D6d732435505fcAbb5511278a1f6B995E723;
        // 0x92703b74131dABA21d78eabFEf1156C7ffe81dE0
        for (uint256 i = 0; i < networkNames.length; i++) {
            vm.createSelectFork(networkNames[i]);
            printPools(user);
        }

        vm.stopBroadcast();
    }
}
