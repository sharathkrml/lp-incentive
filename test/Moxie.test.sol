// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IUniswapV3Factory} from "../src/interfaces/uniswap-v3/IUniswapV3Factory.sol";
import {ISwapRouter} from "../src/interfaces/uniswap-v3/ISwapRouter.sol";
import {IUniswapV3Pool} from "../src/interfaces/uniswap-v3/IUniswapV3Pool.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {INonfungiblePositionManager} from "../src/interfaces/uniswap-v3/INonfungiblePositionManager.sol";
import {
    UNISWAP_V3_FACTORY,
    UNISWAP_V3_SWAP_ROUTER_02,
    MOXIE,
    USDC,
    WETH,
    MOXIE_USDC_POOL,
    UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER
} from "../src/Constants.sol";
import {IUSDC} from "../src/interfaces/IUSDC.sol";
import {Test, console} from "forge-std/Test.sol";

contract MoxieTest is Test {
    address alice = makeAddr("alice");
    // USDC contract address on mainnet
    IUSDC usdc = IUSDC(USDC);
    IERC20 moxie = IERC20(MOXIE);
    // IUniswapV3Factory private factory = IUniswapV3Factory(UNISWAP_V3_FACTORY);
    ISwapRouter private swapRouter = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_02);
    INonfungiblePositionManager private positionManager =
        INonfungiblePositionManager(UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER);

    function setUp() public {
        // spoof .configureMinter() call with the master minter account
        vm.prank(usdc.masterMinter());
        // allow this test contract to mint USDC
        usdc.configureMinter(address(this), type(uint256).max);

        // mint $1000 USDC to the test contract (or an external user)
        usdc.mint(alice, 1000e6);
    }

    // function test_buyMoxie() public {
    //     // approve the swapRouter to spend USDC
    //     vm.startPrank(alice);
    //     usdc.approve(UNISWAP_V3_SWAP_ROUTER_02, 1e6);

    //     uint256 amountOut = swapRouter.exactInputSingle(
    //         ISwapRouter.ExactInputSingleParams({
    //             tokenIn: USDC,
    //             tokenOut: MOXIE,
    //             fee: 3000,
    //             recipient: alice,
    //             amountIn: 1e6,
    //             amountOutMinimum: 0,
    //             sqrtPriceLimitX96: 0
    //         })
    //     );
    //     vm.stopPrank();
    //     console.log("amountOut", amountOut);
    //     uint256 balance = moxie.balanceOf(alice);
    //     console.log("balance", balance);
    // }

    function test_addLiquidity() public {
        // approve the swapRouter to spend USDC
        vm.startPrank(alice);
        usdc.approve(UNISWAP_V3_SWAP_ROUTER_02, 1e6);
        // add liquidity to the MOXIE-USDC pool
        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: MOXIE,
                token1: USDC,
                fee: 3000,
                tickLower: -887272,
                tickUpper: 887272,
                amount0Desired: 1e6,
                amount1Desired: 1e6,
                amount0Min: 0,
                amount1Min: 0,
                recipient: alice,
                deadline: block.timestamp
            })
        );
        vm.stopPrank();
        console.log("tokenId", tokenId);
        console.log("liquidity", liquidity);
        console.log("amount0", amount0);
        console.log("amount1", amount1);
    }
}
