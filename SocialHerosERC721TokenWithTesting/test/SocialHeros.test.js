var SocialHeroToken = artifacts.require("./SocialHeroToken.sol");
const truffleAssert = require('truffle-assertions');


contract('SocialHeroToken', ([owner, operator, ...accounts]) => {

  const tokenName ='SocialHeroToken';
  const symbol='SHERO';
  let token;
  let sender = owner;
  let recipient = operator;

  let tokenId = 0;
  let heroName ="Greta Thunberg";
  let image = "https://www.gstatic.com/tv/thumb/persons/1219098/1219098_v9_aa.jpg";
  let socialImpactSector= "Climate Change";
  let socialImpactFactor= 9;
  let twitterFollowers= 4600000;
  let dob ="2003-01-03";
  const price = '100000000000000000' // 0.1 ether
  const payment = 100000000000000000 // 0.1 ether
  

  before(async () => {
    token = await SocialHeroToken.new(tokenName, symbol);
  })

  it('should have token name and symbol', async () => {
    const myTokenName = await token.name();
    const tokenSymbol = await token.symbol();
    assert(myTokenName===tokenName)
    assert(tokenSymbol===symbol)
  })

  it('should create a Social Hero token and sell it', async () => {
    assert( token.socialHeros.length ===0, "socialHeros should be empty");
    await token.createTokenAndSellSHERO(heroName, socialImpactSector, socialImpactFactor, twitterFollowers, dob,price, image);
    const res = await token.findSHERO(tokenId);
      assert.equal(res[0],twitterFollowers+socialImpactFactor, "Token Id should match");
      assert.equal(res[1],heroName, " Hero Name should match");
      assert.equal(res[2],image, "Image should match");
      assert.equal(res[3],socialImpactSector, "Social Impact Sector should match");
      assert.equal(res[4],socialImpactFactor, "Social Impact Factor should match");
      assert.equal(res[5],twitterFollowers, "Twitter Followers should match");
      assert.equal(res[6],dob, "Date of Birth should match");
      assert.equal(res[7],price, "Price should match");
      assert.equal(res[8],1, "Status should match");
      assert.equal(res[9],sender, "Owner should match");
})


  it('should find Social Hero with matched information', async () => {
      const res = await token.findSHERO(tokenId);
      assert.equal(res[0],twitterFollowers+socialImpactFactor, "Token Id should match");
      assert.equal(res[1],heroName, "Name should match");
      assert.equal(res[2],image, "Image should match");
      assert.equal(res[3],socialImpactSector, "Social Impact Sector should match");
      assert.equal(res[4],socialImpactFactor, "Social Impact Factor should match");
      assert.equal(res[5],twitterFollowers, "Twitter Followers should match");
      assert.equal(res[6],dob, "Date of Birth should match");
      assert.equal(res[7],price, "Price should match");
      assert.equal(res[8],1, "Status should match");
      assert.equal(res[9],sender, "Owner should match");
  })
  it('should buyer purchase SHERO', async () => {
      const resBefore = await token.findSHERO(tokenId);
      assert.equal(resBefore[9],sender, "Owner Address should match");
      await token.buySHERO(tokenId, { from: recipient, gas: 6000000, value: payment  });
      const resAfter = await token.findSHERO(tokenId);
      assert.equal(resAfter[9],recipient, "Owner Address should match");
  })
  it("test: balanceOf function", async () => {
    const _balance = await token.balanceOf(recipient);
    assert.equal(_balance,1, "Balance of Owner does not tally");
  });

  it("test: ownerOf function", async () => {
    const _owner = await token.ownerOf(tokenId);
    assert.equal(_owner,recipient, "Owner Address should match");
  });

  it("test: safetransferFrom(Data) should transfer", async () => {
    
    await token.safeTransferFrom(owner, operator, tokenId, {from: owner,});
    const _owner = await token.ownerOf(tokenId);
    assert.equal(_owner,operator, "New Owner after transfer must be the operator address");
    
  });

  it("test: safetransferFrom() should transfer", async () => {
    
    await token.safeTransferFrom(owner, operator, tokenId, {from: owner,});
    const _owner = await token.ownerOf(tokenId);
    assert.equal(_owner,operator, "New Owner after transfer must be the operator address");
    
  });

  it("test: approve() should approve", async () => {
    
    await token.approve(operator, tokenId);
    const _approvedTo = await token.getApproved(tokenId);
    assert.equal(_approvedTo,operator, "Allowance wasn't added corectly");
    
  });

  it("test: getApproved() should getApproved", async () => {
    const _approvedTo = await token.getApproved(tokenId);
    assert.equal(_approvedTo,operator, "Allowance for operator doesnt match");
  });

  it("test: transferFrom() should transfer", async () => {
    
    await token.transferFrom(operator, owner, tokenId);
    const _owner = await token.ownerOf(tokenId);
    assert.equal(_owner,owner, "New Owner after transfer must be the owner address");
    
  });

  it("test: setApprovalForAll() should approve", async () => {
    
    await token.setApprovalForAll(operator, true);
    const _isApprovedForAll = await token.isApprovedForAll(owner, operator);
    assert.equal(_isApprovedForAll,true, "setApprovalFroAll for operator failed");
    
  });

  it("test: isApprovalForAll() should check approveForAll is set", async () => {
    
    const _isApprovedForAll = await token.isApprovedForAll(owner, operator);
    assert.equal(_isApprovedForAll,true, "isApprovalFroAll for operator returned false");
    
  });

  it("test: Transfer Event emission", async () => {
    let tx = await token.transferFrom(owner, operator, tokenId);
    truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
        return ev.from == owner && ev.to== operator && ev.tokenId==tokenId;
    });
});

it("test: Approval Event emission", async () => {
  let tx = await token.approve(operator, tokenId);
  truffleAssert.eventEmitted(tx, 'Approval', (ev) => {
      return ev.owner == owner && ev.approved== operator && ev.tokenId==tokenId;
  });
});

it("test: ApprovalForAll Event emission", async () => {
  let tx = await token.setApprovalForAll(operator, true);
  truffleAssert.eventEmitted(tx, 'ApprovalForAll', (ev) => {
      return ev.owner == owner && ev.operator== operator && ev.approved==true;
  });
});


})