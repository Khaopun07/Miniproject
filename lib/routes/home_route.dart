import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mathfinity/others/constants.dart';
import 'package:mathfinity/others/states.dart';
import 'package:mathfinity/others/utils.dart';
import 'package:one_context/one_context.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:google_fonts/google_fonts.dart';

Timer? gameTimer;

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  getInfoWidgets(double rowPaddings,
      {String text = "0", IconData icon = Icons.menu, Color? color}) {
    //
    const dividerText = '🕣';
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(rowPaddings),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              dividerText,
              style: GoogleFonts.varelaRound(
                color: Colors.blueGrey,
              ),
            ),
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            Text(
              text,
              style: GoogleFonts.varelaRound(
                fontSize: 24,
                color: color,
              ),
            ),
            Text(
              dividerText,
              style: TextStyle(
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  getResultButtonRippleColor(int index) {
    if (index == states.state.correctAnsIndex) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  getNumberWidget(double numberButtonSizePadding, {int index = 0}) {
    return Expanded(
      child: ElevatedButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.resolveWith(
            (states) {
              return states.contains(MaterialState.pressed)
                  ? getResultButtonRippleColor(index)
                  : null;
            },
          ),
        ),
        onPressed: () async {
          if (states.state.isGameRunning && !states.state.isChangingEquation) {
            states.state.setChangingEquation(true);
            if (states.state.correctAnsIndex == index) {
              states.state.setTotalTrue(states.state.totalTrue + 1);
            } else {
              states.state.setTotalFalse(states.state.totalFalse + 1);
            }
            await Future.delayed(Duration(milliseconds: 250));
            setNewEquationAndResults();
            states.state.setChangingEquation(false);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: numberButtonSizePadding),
          child: AutoSizeText(
            states.state.results[index].toString(),
            style: GoogleFonts.varelaRound(),
            minFontSize: 36,
          ),
        ),
      ),
    );
  }

  onSettingsClicked(double rowPaddings) {
    OneContext.instance.showDialog(
      barrierDismissible: false,
      builder: (p0) {
        return StateBuilder(
          observe: () => states,
          builder: (context, _) {
            return AlertDialog(
              title: Text(
                "การตั้งค่า",
                style: GoogleFonts.varelaRound(),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "จำนวนน้อยที่สุด: ${states.state.minNumber}",
                    style: GoogleFonts.varelaRound(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Slider(
                    min: Constants.minNumber.toDouble(),
                    max: states.state.maxNumber - 1,
                    value: states.state.minNumber.toDouble(),
                    onChanged: (value) {
                      states.state.setMinNumber(value.toInt());
                    },
                  ),
                  Padding(padding: EdgeInsets.all(rowPaddings)),
                  Text(
                    "จำนวนมากที่สุด: ${states.state.maxNumber}",
                    style: GoogleFonts.varelaRound(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Slider(
                    min: states.state.minNumber + 1,
                    max: Constants.maxNumber.toDouble(),
                    value: states.state.maxNumber.toDouble(),
                    onChanged: (value) {
                      states.state.setMaxNumber(value.toInt());
                    },
                  ),
                  Padding(padding: EdgeInsets.all(rowPaddings)),
                  Text(
                    "ตัวจับเวลา: ${states.state.maxTimer}",
                    style: GoogleFonts.varelaRound(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Slider(
                    min: Constants.minTimer.toDouble(),
                    max: Constants.maxTimer.toDouble(),
                    value: states.state.maxTimer.toDouble(),
                    onChanged: (value) {
                      states.state.setMaxTimer(value.toInt());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Utils.saveSettings();
                    Navigator.pop(OneContext.instance.context!);
                  },
                  child: Text(
                    "ตกลง",
                    style: GoogleFonts.varelaRound(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  stopGame() {
    states.state.setGameRunning(!states.state.isGameRunning);
    gameTimer?.cancel();

    showResultDialog();
  }

  showResultDialog() {
    double accuracy;
    if (states.state.totalFalse != 0) {
      accuracy = (states.state.totalTrue /
              (states.state.totalTrue + states.state.totalFalse)) *
          100;
    } else {
      if (states.state.totalFalse + states.state.totalTrue == 0) {
        accuracy = 0;
      } else {
        accuracy = 100.0;
      }
    }
    print("accuracy: $accuracy");

    OneContext.instance.showDialog(
      barrierDismissible: false,
      builder: (p0) {
        return AlertDialog(
          title: Text(
            "เกมจบแล้ว",
            style: GoogleFonts.varelaRound(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                states.state.setTotalTrue(0);
                states.state.setTotalFalse(0);
                states.state.setCurrentTimer(0);
                // OneContext.instance.popAllDialogs();
                Navigator.pop(OneContext.instance.context!);
              },
              child: Text(
                "ตกลง",
                style: GoogleFonts.varelaRound(),
              ),
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "คำตอบที่ถูกต้อง ${states.state.totalTrue}",
                style: GoogleFonts.varelaRound(
                  fontSize: 16,
                ),
              ),
              Text(
                "คำตอบที่ผิด ${states.state.totalFalse}",
                style: GoogleFonts.varelaRound(
                  fontSize: 16,
                ),
              ),
              Text(
                "วินาทีที่เล่น ${states.state.maxTimer - states.state.currentTimer}",
                style: GoogleFonts.varelaRound(
                  fontSize: 16,
                ),
              ),
              Text(
                "ความแม่นยำ ${accuracy.toStringAsFixed(2)}%",
                style: GoogleFonts.varelaRound(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int getMathResult(int num1, int num2, String operator) {
    if (operator == '+') {
      return num1 + num2;
    } else if (operator == '-') {
      return num1 - num2;
    } else if (operator == 'X') {
      return num1 * num2;
    } else if (operator == '/') {
      return num1 ~/ num2;
    }

    return 0;
  }

  setNewEquationAndResults() {
    var numbersArray = Utils.generateNumberArray(
      states.state.minNumber,
      states.state.maxNumber,
      shuffle: true,
    );

    int num1 = numbersArray[0];
    int num2 = numbersArray[1];

    // int num1 = 98;
    // int num2 = 99;

    if (num2 > num1) {
      int temp = num1;
      num1 = num2;
      num2 = temp;
    }

    var operators = ["+", "-", "X", "/"];
    operators = Utils.shuffleArray<String>(operators);
    var op0 = operators[0];
    states.state.setCurrentOperator(op0);

    if (op0 == "/") {
      int mod = num1 % num2;
      num1 -= mod;
    }
    var answer = getMathResult(num1, num2, op0);

    if (num1 == num2 || answer < 3) {
      return setNewEquationAndResults();
    }

    states.state.setFirstNumber(num1);
    states.state.setSecondNumber(num2);

    List<int> results = Utils.generateNumbersCloseTo(answer);
    operators = Utils.shuffleArray<String>(operators);

    for (var i = 0; i < operators.length; i++) {
      if (operators[i] == op0) {
        results[i] = answer;
        states.state.setCorrectAnsIndex(i);
        break;
      }
    }
    states.state.setResults(results);
  }

  startGame() {
    states.state.setGameRunning(!states.state.isGameRunning);
    states.state.setCurrentTimer(states.state.maxTimer);

    setNewEquationAndResults();
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      int timeLeft = states.state.maxTimer - timer.tick;
      states.state.setCurrentTimer(timeLeft);

      if (timeLeft <= 0) {
        stopGame();
      }
    });
  }

  onStartStopClicked() {
    if (states.state.isGameRunning) {
      stopGame();
    } else {
      startGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenHeight = size.height;
    double rowPaddings = screenHeight / 100;
    double numberButtonSizePadding = screenHeight / 19;

    return StateBuilder(
      observe: () => states,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            "MathFinity",
            style: GoogleFonts.varelaRound(
              color: Theme.of(OneContext.instance.context!).colorScheme.primary,
              // fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: states.state.isGameRunning
                  ? null
                  : () {
                      onSettingsClicked(rowPaddings);
                    },
              icon: Icon(
                Icons.settings,
                color: states.state.isGameRunning
                    ? Colors.grey
                    : Theme.of(OneContext.instance.context!)
                        .colorScheme
                        .primary,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                getInfoWidgets(
                  rowPaddings,
                  icon: Icons.check_circle,
                  color: Theme.of(OneContext.instance.context!)
                      .colorScheme
                      .primary,
                  text: states.state.totalTrue.toString(),
                ),
                getInfoWidgets(
                  rowPaddings,
                  icon: states.state.currentTimer % 2 == 0
                      ? Icons.hourglass_bottom
                      : Icons.hourglass_top,
                  color:
                      Theme.of(OneContext.instance.context!).colorScheme.error,
                  text: states.state.currentTimer.toString(),
                ),
                getInfoWidgets(
                  rowPaddings,
                  icon: Icons.cancel,
                  color:
                      Theme.of(OneContext.instance.context!).colorScheme.error,
                  text: states.state.totalFalse.toString(),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(rowPaddings)),
            Text(
              "${states.state.firstNumber} ${states.state.currentOperator} ${states.state.secondNumber}",
              style: GoogleFonts.varelaRound(
                fontSize: 36,
                // color:
                //     Theme.of(OneContext.instance.context!).colorScheme.primary,
                fontWeight: FontWeight.w500,
                letterSpacing: 12,
              ),
            ),
            Padding(padding: EdgeInsets.all(rowPaddings)),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: rowPaddings,
                horizontal: rowPaddings * 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getNumberWidget(numberButtonSizePadding, index: 0),
                  Padding(padding: EdgeInsets.all(rowPaddings)),
                  getNumberWidget(numberButtonSizePadding, index: 1),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: rowPaddings,
                horizontal: rowPaddings * 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getNumberWidget(numberButtonSizePadding, index: 2),
                  Padding(padding: EdgeInsets.all(rowPaddings)),
                  getNumberWidget(numberButtonSizePadding, index: 3),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(rowPaddings)),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith(
                          (buttonState) {
                            getColor() {
                              if (states.state.isGameRunning) {
                                return Colors.red;
                              } else {
                                return Colors.green;
                              }
                            }

                            return buttonState.contains(MaterialState.pressed)
                                ? getColor()
                                : null;
                          },
                        ),
                      ),
                      onPressed: () {
                        onStartStopClicked();
                        // setEquationAndResults();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          states.state.isGameRunning ? "หยุด" : "เริ่ม",
                          style: GoogleFonts.varelaRound(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
