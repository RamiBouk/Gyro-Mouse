import 'dart:io';
import 'dart:typed_data';
import 'package:process_run/shell.dart';

Stream<String> gyro(String hey) async* {
  while (true) {
    yield hey;
  }
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}

void main() async {
  String deltax, deltay;
  var shell = Shell(commandVerbose: true);

  // bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4567);

  // listen for clent connections to the server
  server.listen((client) {
    // listen for events from the client
    client.listen(
      // handle data from the client
      (data) async {
        var messages = String.fromCharCodes(data).toString().split(' ');
        messages.removeWhere((element) => element == '');
        for (final message in messages) {
          switch (message) {
            case "mouse1":
              await shell.run('xdotool click 1 ');
              break;

            case "mouse2":
              await shell.run('xdotool click 3 ');
              break;
            case "hold":
              await shell.run('xdotool mousedown 1 ');
              break;

            case "release":
              await shell.run('xdotool mouseup 1 ');

              break;

            case "scrollUp":
              // await shell.run('xdotool mouseup ');
              await shell.run('xdotool click 4');
              break;

            case "scrollDown":
              // await shell.run('xdotool mouseup 1 ');
              await shell.run('xdotool click 5');
              break;
            case "pgUp":
              // await shell.run('xdotool mouseup 1 ');
              await shell.run(' xdotool key Page_Up');
              break;
            case "pgDown":
              // await shell.run('xdotool mouseup 1 ');
              await shell.run(' xdotool key Page_Down');
              break;

            default:
              try {
                if (message.split('|').isNotEmpty) {
                  deltay = message.split('|')[0];
                  deltax = message.split('|')[1];
                  print(message.toString());
                  if (isNumeric(deltay) && isNumeric(deltax))
                    await shell.run('xdotool mousemove_relative -- ' +
                        deltax +
                        ' ' +
                        deltay);
                }
              } catch (e) {
                print(message.toString());
              }
          }
        }
      },

      // handle errors

      onError: (error) {
        print(error);
        client.close();
      },

      // handle the client closing the connection
      onDone: () {
        print('Client left');
        //client.close();
      },
    );
  });
}
