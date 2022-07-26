const NftMarketPalace = artifacts.require("NftMarket");

module.exports = function (deployer) {
  deployer.deploy( NftMarketPalace);
};
