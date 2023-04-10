// ignore_for_file: camel_case_types, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:green_house_app/screens/LiveChat/Room.dart';
import 'package:green_house_app/screens/LiveChat/exts.dart';
import 'package:green_house_app/screens/LiveChat/theme.dart';
import 'package:green_house_app/screens/LiveChat/utils.dart';
import 'package:livekit_client/livekit_client.dart';

import 'widgets/LKtextField.dart';

class ConnectPage extends StatefulWidget {
  //
  const ConnectPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  //
  static const _storeKeyUri = 'uri';
  static const _storeKeyToken = 'token';
  static const _storeKeySimulcast = 'simulcast';

  final _uriCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _simulcast = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    readPrefs();
  }

  @override
  void dispose() {
    _uriCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect(BuildContext ctx) async {
    //
    try {
      setState(() {
        _busy = true;
      });

      // Save URL and Token for convenience
      await writePrefs();

      print('Connecting with url: ${_uriCtrl.text}, '
          'token: ${_tokenCtrl.text}...');

      // Try to connect to a room
      // This will throw an Exception if it fails for any reason.
      final room = await LiveKitClient.connect(
        _uriCtrl.text,
        _tokenCtrl.text,
        roomOptions: RoomOptions(
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: _simulcast,
          ),
        ),
      );

      await Navigator.push<void>(
        ctx,
        MaterialPageRoute(builder: (_) => RoomPage(room)),
      );
    } catch (error) {
      print('Could not connect $error');
      await ctx.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  void _setSimulcast(bool? value) async {
    if (value == null || _simulcast == value) return;
    setState(() {
      _simulcast = value;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: SvgPicture.asset(
                      'images/logo-dark.svg',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: LKTextField(
                      label: 'Server URL',
                      ctrl: _uriCtrl,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: LKTextField(
                      label: 'Token',
                      ctrl: _tokenCtrl,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Simulcast'),
                        Switch(
                          value: _simulcast,
                          onChanged: (value) => _setSimulcast(value),
                          inactiveTrackColor: Colors.white.withOpacity(.2),
                          activeTrackColor: LKColors.lkBlue,
                          inactiveThumbColor: Colors.white.withOpacity(.5),
                          activeColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _busy ? null : () => _connect(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_busy)
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        const Text('CONNECT'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
