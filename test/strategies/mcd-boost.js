const hre = require('hardhat');
const { expect } = require('chai');

const dfs = require('@defisaver/sdk');

const { ilks } = require('@defisaver/tokens');

const {
    getProxy, redeploy, fetchAmountinUSDPrice, formatExchangeObj, DAI_ADDR,
} = require('../utils');

const { createBundle, createStrategy, addBotCaller } = require('../utils-strategies.js');

const { getRatio } = require('../utils-mcd.js');

const { subMcdBoostStrategy, callMcdBoostStrategy, callFLMcdBoostStrategy } = require('../strategies');

const { openVault } = require('../actions');

describe('Mcd-Boost-Strategy', function () {
    this.timeout(320000);

    let senderAcc;
    let proxy;
    let botAcc;
    let strategyExecutor;
    let subId;
    let strategySub;
    let vaultId;
    let mcdView;
    let flDyDx;

    const ethJoin = ilks[0].join;

    const createMcdBoostStrategy = () => {
        const mcdBoostStrategy = new dfs.Strategy('MakerBoostStrategy');
        mcdBoostStrategy.addSubSlot('&vaultId', 'uint256');
        mcdBoostStrategy.addSubSlot('&targetRatio', 'uint256');

        const mcdRatioTrigger = new dfs.triggers.MakerRatioTrigger('0', '0', '0');
        mcdBoostStrategy.addTrigger(mcdRatioTrigger);

        const generateAction = new dfs.actions.maker.MakerGenerateAction(
            '&vaultId',
            '%generateAmount',
            '&proxy',
            '%managerAddr',
        );

        const sellAction = new dfs.actions.basic.SellAction(
            formatExchangeObj(
                '%daiAddr',
                '%wethAddr',
                '$1',
                '%wrapper',
            ),
            '&proxy',
            '&proxy',
        );

        const feeTakingAction = new dfs.actions.basic.GasFeeAction(
            '0', '%wethAddr', '$2',
        );

        const mcdSupplyAction = new dfs.actions.maker.MakerSupplyAction(
            '&vaultId', // vaultId
            '$3', // amount
            '%ethJoin',
            '&proxy', // proxy
            '%mcdManager',
        );

        const mcdRatioCheckAction = new dfs.actions.checkers.MakerRatioCheckAction(
            '&targetRatio', // targetRatio
            '&vaultId', // vaultId
            '%nextPrice', // nextPrice
        );

        mcdBoostStrategy.addAction(generateAction);
        mcdBoostStrategy.addAction(sellAction);
        mcdBoostStrategy.addAction(feeTakingAction);
        mcdBoostStrategy.addAction(mcdSupplyAction);
        mcdBoostStrategy.addAction(mcdRatioCheckAction);

        return mcdBoostStrategy.encodeForDsProxyCall();
    };

    const createFlMcdBoostStrategy = () => {
        const mcdBoostStrategy = new dfs.Strategy('MakerFLBoostStrategy');
        mcdBoostStrategy.addSubSlot('&vaultId', 'uint256');
        mcdBoostStrategy.addSubSlot('&targetRatio', 'uint256');

        const mcdRatioTrigger = new dfs.triggers.MakerRatioTrigger('0', '0', '0');
        mcdBoostStrategy.addTrigger(mcdRatioTrigger);

        const flAction = new dfs.actions.flashloan.DyDxFlashLoanAction('%amount', DAI_ADDR);

        const sellAction = new dfs.actions.basic.SellAction(
            formatExchangeObj(
                '%daiAddr',
                '%wethAddr',
                '$1',
                '%wrapper',
            ),
            '&proxy',
            '&proxy',
        );

        const feeTakingAction = new dfs.actions.basic.GasFeeAction(
            '0', '%wethAddr', '$2',
        );

        const mcdSupplyAction = new dfs.actions.maker.MakerSupplyAction(
            '&vaultId', // vaultId
            '$3', // amount
            '%ethJoin',
            '&proxy', // proxy
            '%mcdManager',
        );

        const generateAction = new dfs.actions.maker.MakerGenerateAction(
            '&vaultId',
            '$1',
            '%FLAddr',
            '%managerAddr',
        );

        mcdBoostStrategy.addAction(flAction);
        mcdBoostStrategy.addAction(sellAction);
        mcdBoostStrategy.addAction(feeTakingAction);
        mcdBoostStrategy.addAction(mcdSupplyAction);
        mcdBoostStrategy.addAction(generateAction);

        return mcdBoostStrategy.encodeForDsProxyCall();
    };

    before(async () => {
        senderAcc = (await hre.ethers.getSigners())[0];
        botAcc = (await hre.ethers.getSigners())[1];

        await redeploy('BotAuth');
        await redeploy('ProxyAuth');
        await redeploy('McdRatioTrigger');
        await redeploy('McdWithdraw');
        await redeploy('DFSSell');
        await redeploy('McdPayback');
        await redeploy('StrategyStorage');
        await redeploy('SubStorage');
        await redeploy('BundleStorage');

        mcdView = await redeploy('McdView');

        await redeploy('SubProxy');
        await redeploy('StrategyProxy');
        await redeploy('RecipeExecutor');
        await redeploy('GasFeeTaker');
        await redeploy('McdRatioCheck');
        strategyExecutor = await redeploy('StrategyExecutor');

        flDyDx = await redeploy('FLDyDx');
        await redeploy('McdSupply');
        await redeploy('McdWithdraw');
        await redeploy('McdGenerate');
        await redeploy('McdPayback');
        await redeploy('McdOpen');

        await addBotCaller(botAcc.address);

        proxy = await getProxy(senderAcc.address);
    });

    it('... should create 2 boost strategies and create a bundle', async () => {
        const boostStrategy = createMcdBoostStrategy();
        const flBoostStrategy = createFlMcdBoostStrategy();

        await createStrategy(proxy, ...boostStrategy, true);
        await createStrategy(proxy, ...flBoostStrategy, true);

        await createBundle(proxy, [0, 1]);
    });

    it('... should sub to boost bundle', async () => {
        vaultId = await openVault(
            proxy,
            'ETH-A',
            fetchAmountinUSDPrice('WETH', '30000'),
            fetchAmountinUSDPrice('DAI', '12000'),
        );

        console.log('VaultId: ', vaultId);

        const rationOver = hre.ethers.utils.parseUnits('1.7', '18');
        const targetRatio = hre.ethers.utils.parseUnits('2', '18');

        const bundleId = 0;

        ({ subId, strategySub } = await subMcdBoostStrategy(
            proxy,
            bundleId,
            vaultId,
            rationOver,
            targetRatio,
            true,
        ));
    });

    it('... should sub to boost bundle', async () => {
        vaultId = await openVault(
            proxy,
            'ETH-A',
            fetchAmountinUSDPrice('WETH', '30000'),
            fetchAmountinUSDPrice('DAI', '12000'),
        );

        console.log('VaultId: ', vaultId);

        const rationOver = hre.ethers.utils.parseUnits('1.7', '18');
        const targetRatio = hre.ethers.utils.parseUnits('2', '18');

        const bundleId = 0;

        ({ subId, strategySub } = await subMcdBoostStrategy(
            proxy,
            bundleId,
            vaultId,
            rationOver,
            targetRatio,
            true,
        ));
    });

    it('... should trigger a maker boost strategy', async () => {
        const ratioBefore = await getRatio(mcdView, vaultId);
        const boostAmount = hre.ethers.utils.parseUnits(fetchAmountinUSDPrice('DAI', '2000'), '18');

        await callMcdBoostStrategy(
            botAcc,
            strategyExecutor,
            0,
            subId,
            ethJoin,
            boostAmount,
            strategySub,
        );

        const ratioAfter = await getRatio(mcdView, vaultId);

        console.log(
            `Ratio before ${ratioBefore.toString()} -> Ratio after: ${ratioAfter.toString()}`,
        );

        expect(ratioBefore).to.be.gt(ratioAfter);
    });

    it('... should trigger a maker FL boost strategy', async () => {
        const ratioBefore = await getRatio(mcdView, vaultId);
        const boostAmount = hre.ethers.utils.parseUnits(fetchAmountinUSDPrice('DAI', '400'), '18');

        // eslint-disable-next-line max-len
        await callFLMcdBoostStrategy(botAcc, strategyExecutor, 1, flDyDx.address, subId, ethJoin, boostAmount, strategySub);

        const ratioAfter = await getRatio(mcdView, vaultId);

        console.log(
            `Ratio before ${ratioBefore.toString()} -> Ratio after: ${ratioAfter.toString()}`,
        );

        expect(ratioBefore).to.be.gt(ratioAfter);
    });
});
