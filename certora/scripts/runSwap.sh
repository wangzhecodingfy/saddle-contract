
if [[ "$1" ]]
then
    RULE="--rule $1"
fi
certoraRun \
    certora/harness/SwapHarness.sol \
    certora/munged/LPToken.sol \
    --verify SwapHarness:certora/spec/Swap.spec \
    --structLink SwapHarness:lpToken=LPToken \
    --cache saddle \
    --loop_iter 2 \
    --settings -copyLoopUnroll=10,-t=2000,-mediumTimeout=200,-depth=100 \
    $RULE \
    --send_only \
    --msg "Swap $1 $2" \
    --staging release/19Sep2022 \
    --optimistic_loop \
    --rule_sanity
    # --staging yoav/array_of_structs_fix \
    # --settings -enableEqualitySaturation=false \

#--rules cantReinitonlyAdminCanSetSwapFeesonlyAdminCanSetAdminFeespausedMeansLPMonotonicallyDecreasesunderlyingTokensDifferentInitialized

#--rules uninitializedImpliesZeroValueuninitializedImpliesRevertonlyRemoveLiquidityOneTokenDecreasesUnderlyingsOnesidedremoveLiquidityDoesntReduceAdminFeesLPSupplyZeroMeansBalancesZero

#--rules monotonicallyIncreasingFeesonlyAdminCanWithdrawFeespausedImpliesNoSingleTokenWithdrawalpausedImpliesTokenRatioConstantvirtualPriceNeverZeroOnceLiquidityProvided

#--rules swappingCheckMinAmount onlyAddLiquidityCanInitialize addLiquidityCheckMinToMint swapAlwaysBeforeDeadline addLiquidityAlwaysBeforeDeadline

#--rules removeLiquidityAlwaysBeforeDeadline onlyRemoveLiquidityImbalanceDecreasesVirtualPrice LPtotalSupplyZeroWhenUninitialized

#--rules uninitializedImpliesZeroValueInv underlyingTokensDifferent LPsolvency underlyingsSolvency zeroTokenAZeroTokenB

#--rules uninitializedMeansUnderlyingsZeroadminFeeNeverGreaterThanMAXswapFeeNeverGreaterThanMAXifLPTotalSupplyZeroThenIndividualUnderlyingsZeroifSumUnderlyingsZeroLPTotalSupplyZero

