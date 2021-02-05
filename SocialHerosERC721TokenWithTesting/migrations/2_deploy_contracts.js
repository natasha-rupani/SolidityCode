var socialHeroToken = artifacts.require("./SocialHeroToken.sol");

module.exports = (deployer, network, accounts) => {
  deployer.then(async () => {
    try {
      await deployer.deploy(SocialHeroToken);
    } catch (err) {
      console.log(('Failed to Deploy Contracts', err))
    }
  })

}