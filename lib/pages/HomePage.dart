import 'package:animated_button/animated_button.dart';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pulswap/pages/CheckoutPage.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 40),
            child: Container(
              width: 400,
              child: BoxForm(),
            ),
          ),
        ],
      ),
    );
  }
}

class BoxForm extends StatefulWidget {
  const BoxForm({super.key});

  @override
  State<BoxForm> createState() => _BoxFormState();
}

class _BoxFormState extends State<BoxForm> {
  Client? httpClient;
  Web3Client? ethClient;
  final sellerAddress = "0x2E6559665f3beB4e0eF2227Da70d89920e570dA3";

  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://goerli.infura.io/v3/a105a0c5d84740c3a0b07658d4f7f6be",
        httpClient!);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x355B198Ff0bF74d2adc14A575581E012487A7846";
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, "Pulswapv2"),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
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

  Future<String> purchase(int amount) async {
    var bigAmount = BigInt.from(amount);
    var response = await submit("purchase", [bigAmount]);
    print("Purchased");
    return response;
  }

  @override
  List<String> Providers = ['Telkomsel', 'XL', 'Axis'];
  List<String> Nominals = ['5000', '10000', '15000', '25000', '50000'];
  String? selectedProvider;
  String? selectedNominal;
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'PRE-PAID PULSE',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        SizedBox(height: 30),
        CustomDropdownButton2(
          hint: 'Select Providers',
          buttonWidth: 300,
          buttonHeight: 60,
          dropdownWidth: 300,
          dropdownItems: Providers,
          value: selectedProvider,
          onChanged: (value) {
            setState(() {
              selectedProvider = value;
            });
          },
        ),
        SizedBox(
          height: 5,
        ),
        CustomDropdownButton2(
          hint: 'Nominals',
          buttonWidth: 300,
          buttonHeight: 60,
          dropdownWidth: 300,
          dropdownItems: Nominals,
          value: selectedNominal,
          onChanged: (value) {
            setState(() {
              selectedNominal = value;
            });
          },
        ),
        SizedBox(
          height: 10,
        ),
        AnimatedButton(
          width: 300,
          color: Colors.green,
          child: Text(
            'B U Y',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            purchase(int.parse("5000"));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckoutPage()),
            );
          },
        ),
      ],
    );
  }
}
