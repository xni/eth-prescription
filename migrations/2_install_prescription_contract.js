var Prescriptions = artifacts.require("./Prescriptions.sol");

module.exports = function(deployer) {
  deployer.deploy(Prescriptions);
};
