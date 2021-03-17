import Web3 from "web3";
import metaCoinArtifact from "../../build/contracts/Insurance.json";

const App = {
  web3: null,
  account: null,
  meta: null,

  start: async function() {
    const { web3 } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = metaCoinArtifact.networks[networkId];
      this.meta = new web3.eth.Contract(
        metaCoinArtifact.abi,
        deployedNetwork.address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];

      this.refreshBalance();
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },

   refreshBalance: async function() {
    const { getBalance } = this.meta.methods;
    const balance = await getBalance(this.account).call();

    const balanceElement = document.getElementsByClassName("balance")[0];
    balanceElement.innerHTML = balance;
  },

   addProduct: async function() {
    const prodectId = parseInt(document.getElementById("productId").value);
    const productName = document.getElementById("productName").value;
    const price = parseInt(document.getElementById("price").value);
    //const Owner = document.getElementById("productOwnerAddress").value;
    //const amount = parseInt(document.getElementById("amount").value);
    //const receiver = document.getElementById("receiver").value;

    this.setStatus("Initiating transaction... (please wait)");

    const { addProduct } = this.meta.methods;
    await addProduct(prodectId,productName,price, this.account).send({from: this.account });

    this.setStatus("You add a product " + this.account);
    this.refreshBalance();
  },
  
  buyProduct: async function(){
	  const { buyInsurance } = this.meta.methods;
    const prodiDB = parseInt(document.getElementById("productIDB").value);
    const price = document.getElementById("cAddress").value;
    //console.log(prodiDB, cAddress)
    await buyInsurance(prodiDB).send({from: this.account,value:price }); // 
    //get
  },
  getProduct: async function(){
	  const { fetch } = this.meta.methods;
	  const prodiD = parseInt(document.getElementById("productId1").value);
	  const prodD = await fetch(prodiD).call(); // <- prodcutId1
	  const prodElement = document.getElementsByClassName("fProduct");
	  prodElement[0].innerHTML = prodD[0];
    prodElement[1].innerHTML = prodD[1];
    prodElement[2].innerHTML = prodD[2];
    prodElement[3].innerHTML = prodD[3];
    prodElement[4].innerHTML = prodD[4];
    console.log(prodD)
  },

  setStatus: function(message) {
    const status = document.getElementById("status");
    status.innerHTML = message;
  },
};

window.App = App;

window.addEventListener("load", function() {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn(
      "No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live",
    );
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:8545"),
    );
  }

  App.start();
});
