const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'ws://localhost:9545');
const Dice = artifacts.require('DiceMultisig');



describe('Testset for Dice', () => {
  let dice = null;
  let accounts = null;
  before(async () => {
    dice = await Dice.deployed();
    accounts = await web3.eth.getAccounts();
  })


  it('Should deploy smart contract properly', async () => {
    console.log(dice.address);
    assert(dice.address !== '');
  });

  it('Should roll value as [0-12]', async () => {
    await dice.roll();
    const result = await dice.getMyScore();
    assert(result >= 0 && result <=12);
  });

  it('Should return correct value', async () => {
    await dice.roll();
    const gets = await dice.getMyScore();
    const saved = await dice.score(accounts[0]);
    //console.log(accounts);
    assert(gets.toNumber() === saved.toNumber());
  });

  /*it('Should roll value as [0-12] (50 iterations)', async () => {
    for(i = 0; i < 50; i++){
      await dice.roll();
      const result = await dice.getMyScore();
      //console.log(result);
      assert(result >= 0 && result <=12);
    }
  });*/

});

