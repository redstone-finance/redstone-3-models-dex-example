import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {ethers, getUnnamedAccounts} from 'hardhat';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;
  const [deployer] = await getUnnamedAccounts();

  const Usd = await ethers.getContract("Usd");

  await deploy('DexCore', {
    from: deployer,
    args: [Usd.address],
    log: true,
  });
};
export default func;
func.tags = ['DexCore'];