import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  Client? httpClient;
  Web3Client? ethClient;
  bool data = false;
  final sellerAddress = "0x2E6559665f3beB4e0eF2227Da70d89920e570dA3";
  var balance;
  var walletbalance;

  TextEditingController controller = TextEditingController();
  // int balance = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://goerli.infura.io/v3/a105a0c5d84740c3a0b07658d4f7f6be",
        httpClient!);

    getBalance(sellerAddress);
    getBalanceWallet(sellerAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    // String contractAddress = "0x282c4B9e0e8D2b093310d78EF53092514793Aba4";
    String contractAddress = "0x355B198Ff0bF74d2adc14A575581E012487A7846";
    // final contract = DeployedContract(ContractAbi.fromJson(abi, "Pulswap"),
    //     EthereumAddress.fromHex(contractAddress));
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, "Pulswapv2"),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient!
        .call(contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    loading = true;
    setState(() {});
    List<dynamic> result = await query("getBalance", []);
    balance = int.parse(result[0].toString());
    loading = false;
    setState(() {});
  }

  Future<String> getBalanceWallet(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    loading = true;
    setState(() {});
    final result = await ethClient!.getBalance(address);

    walletbalance = result.toString();
    loading = false;
    setState(() {});
    return walletbalance;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "de35478b5334d70050cb415108ea16e9b0b55cd6b14463fba81a2e34fe90bce6");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient!.sendTransaction(
      credentials,
      Transaction.callContract(
          contract: contract, function: ethFunction, parameters: args),
      fetchChainIdFromNetworkId: true,
      chainId: null,
    );
    return result;
  }

  Future<String> sendCoin(int amount) async {
    var bigAmount = BigInt.from(amount);
    var response = await submit("deposit", [bigAmount]);
    print("Deposited");
    return response;
  }

  Future<String> withdrawCoin(int amount) async {
    var bigAmount = BigInt.from(amount);
    var response = await submit("withdrawBalance", [bigAmount]);
    print("Withdrawn");
    return response;
  }

  Widget build(BuildContext context) {
    return Container(
      // width: 400,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 40),
            child: Column(
              // width: 400,
              children: [
                Text(
                  'BALANCES',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.green),
                ),
                loading
                    ? CircularProgressIndicator()
                    : Text(
                        // balances,
                        balance.toString(),
                        style: TextStyle(
                            fontSize: 50, fontWeight: FontWeight.w500),
                      ),
                SizedBox(
                  width: 350,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        filled: true,
                        hintText: 'Input Nominals (Rupiah)',
                        // helperText: 'Please Input with wei nominals',
                        fillColor: Color.fromARGB(255, 244, 244, 244),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        )),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                loading
                    ? CircularProgressIndicator()
                    : Text(
                        // balances,
                        walletbalance,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AnimatedButton(
                      width: 100,
                      height: 50,
                      color: Colors.blue,
                      child: Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        // getBalances(sellerAddress);
                        getBalance(sellerAddress);
                      },
                    ),
                    AnimatedButton(
                      width: 100,
                      height: 50,
                      color: Colors.green,
                      child: Text(
                        'Deposit',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => sendCoin(int.parse(controller.text)),
                      // onPressed: () => deposit(int.parse(controller.text)),
                    ),
                    AnimatedButton(
                      width: 100,
                      height: 50,
                      color: Colors.red,
                      child: Text(
                        'Withdraw',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        withdrawCoin(int.parse(controller.text));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
