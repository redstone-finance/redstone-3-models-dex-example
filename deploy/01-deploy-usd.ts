import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import { getUnnamedAccounts } from 'hardhat';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const [deployer] = await getUnnamedAccounts();

  console.log("Deploying USD");

  await deploy('Usd', {
    from: deployer,
    args: [1000000],
    log: true,
  });
};
export default func;
func.tags = ['Usd'];