import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CountUpPage(),
    );
  }
}

class CountUpPage extends StatefulWidget {
  const CountUpPage({super.key});

  @override
  State<CountUpPage> createState() => _CountUpPageState();
}

class _CountUpPageState extends State<CountUpPage> {
  final _stopWatchTimer = StopWatchTimer();

  final _scrollController = ScrollController();

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('assets/images/background_type_t.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreamBuilder<int>(
                          stream: _stopWatchTimer.rawTime,
                          initialData: _stopWatchTimer.rawTime.value,
                          builder: (context, snapshot) {
                            final displayTime = StopWatchTimer.getDisplayTime(
                              snapshot.data!,
                            );
                            return Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  displayTime,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontFamily: 'Courier',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 80,
                          child: StreamBuilder<List<StopWatchRecord>>(
                            stream: _stopWatchTimer.records,
                            initialData: const [],
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<List<StopWatchRecord>> snapshot,
                            ) {
                              final value = snapshot.data;
                              if (value!.isEmpty) {
                                return const Text(
                                  'No Record',
                                  style: TextStyle(
                                    fontFamily: 'Courier',
                                  ),
                                );
                              }
                              return ListView.builder(
                                controller: _scrollController,
                                itemCount: value.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final data = value[index];
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          '${index + 1} ${data.displayTime}',
                                          style: const TextStyle(
                                            fontFamily: 'Courier',
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // リセットボタン
                      GestureDetector(
                        onTap: () {
                          _stopWatchTimer.onResetTimer();
                          setState(() {
                            isPlaying = false;
                          });
                        },
                        child: const SizedBox(
                          width: 80,
                          height: 80,
                          child: Center(
                            child: Icon(
                              Icons.restart_alt,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 24,
                      ),

                      // 再生・停止ボタン
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                          if (isPlaying == true) {
                            _stopWatchTimer.onStartTimer();
                          } else {
                            _stopWatchTimer.onStopTimer();
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      // ラップボタン
                      GestureDetector(
                        onTap: () async {
                          if (!_stopWatchTimer.isRunning) {
                            return;
                          }
                          _stopWatchTimer.onAddLap();
                          await Future<void>.delayed(
                              const Duration(milliseconds: 100));
                          await _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        },
                        child: const SizedBox(
                          width: 80,
                          height: 80,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
