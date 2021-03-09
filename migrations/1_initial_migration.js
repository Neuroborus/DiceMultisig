const DiceMultisig = artifacts.require("DiceMultisig");

module.exports = function(deployer) {
  deployer.deploy(DiceMultisig);
};
