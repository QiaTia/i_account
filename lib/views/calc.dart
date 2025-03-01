
import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String currentInput = '0';
  String previousInput = '';
  String operator = '';
  double result = 0;

  void pressButton(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        currentInput = '0';
        previousInput = '';
        operator = '';
        result = 0;
      } else if (buttonText == '+/-') {
        if (currentInput.startsWith('-')) {
          currentInput = currentInput.substring(1);
        } else {
          currentInput = '-' + currentInput;
        }
      } else if (buttonText == '%') {
        try {
          double value = double.parse(currentInput);
          currentInput = (value / 100).toString();
        } catch (e) {
          currentInput = 'Error';
        }
      } else if (buttonText == '+' || buttonText == '-' || buttonText == '×' || buttonText == '÷') {
        if (currentInput != '') {
          previousInput = currentInput;
          operator = buttonText;
          currentInput = '';
        }
      } else if (buttonText == '=') {
        if (operator != '' && currentInput != '') {
          try {
            double prevValue = double.parse(previousInput);
            double currentValue = double.parse(currentInput);
            switch (operator) {
              case '+':
                result = prevValue + currentValue;
                break;
              case '-':
                result = prevValue - currentValue;
                break;
              case '×':
                result = prevValue * currentValue;
                break;
              case '÷':
                result = prevValue / currentValue;
                break;
            }
            currentInput = result.toStringAsFixed(2).replaceAll('.00', '');
            previousInput = '';
            operator = '';
          } catch (e) {
            currentInput = 'Error';
          }
        }
      } else {
        if (currentInput == '0') {
          currentInput = buttonText;
        } else {
          currentInput += buttonText;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        // backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              color: Colors.black,
              child: Text(
                currentInput,
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton('AC', Colors.grey.shade300, Colors.black, () => pressButton('AC')),
                    buildButton('+/-', Colors.grey.shade300, Colors.black, () => pressButton('+/-')),
                    buildButton('%', Colors.grey.shade300, Colors.black, () => pressButton('%')),
                    buildOperatorButton('÷', () => pressButton('÷')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildNumberButton('7', () => pressButton('7')),
                    buildNumberButton('8', () => pressButton('8')),
                    buildNumberButton('9', () => pressButton('9')),
                    buildOperatorButton('×', () => pressButton('×')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildNumberButton('4', () => pressButton('4')),
                    buildNumberButton('5', () => pressButton('5')),
                    buildNumberButton('6', () => pressButton('6')),
                    buildOperatorButton('-', () => pressButton('-')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildNumberButton('1', () => pressButton('1')),
                    buildNumberButton('2', () => pressButton('2')),
                    buildNumberButton('3', () => pressButton('3')),
                    buildOperatorButton('+', () => pressButton('+')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: buildNumberButton('0', () => pressButton('0')),
                    ),
                    buildNumberButton('.', () => pressButton('.')),
                    buildOperatorButton('=', () => pressButton('=')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(bgColor),
        foregroundColor: MaterialStateProperty.all<Color>(textColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        elevation: MaterialStateProperty.resolveWith<double>((states) {
          if (states.contains(MaterialState.pressed)) {
            return 0;
          }
          return 5;
        }),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget buildNumberButton(String text, VoidCallback onPressed) {
    return buildButton(text, Colors.grey.shade800, Colors.white, onPressed);
  }

  Widget buildOperatorButton(String text, VoidCallback onPressed) {
    return buildButton(text, Colors.orangeAccent, Colors.white, onPressed);
  }
}
