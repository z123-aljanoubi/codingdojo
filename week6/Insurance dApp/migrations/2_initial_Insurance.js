const insurance = artifacts.require("Insurance");

module.exports = function(deployer) {
  
  deployer.deploy(insurance);
};
