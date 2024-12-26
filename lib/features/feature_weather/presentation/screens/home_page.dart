import 'package:flutter/material.dart';
import 'package:weather/core/widgets/app_background.dart';
import 'package:weather/features/feature_weather/domain/entities/current_city_entity.dart';
import 'package:weather/features/feature_weather/presentation/bloc/cw_status.dart';
import 'package:weather/features/feature_weather/presentation/bloc/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String cityName = "mashhad";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(cityName));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final Logger logger = Logger();
    return SafeArea(
        child: Column(
      children: [
        SizedBox(
          height: height * 0.02,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.03),
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) {
              if (previous.cwStatus == current.cwStatus) {
                return false;
              } else {
                return true;
              }
            },
            builder: (context, state) {
              if (state.cwStatus is CwLoading) {
                return const CircularProgressIndicator();
              } else if (state.cwStatus is CwError) {
                final CwError cwErrore = state.cwStatus as CwError;
                logger.w(cwErrore.message);
                return IconButton(
                  onPressed: () {
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //   content: Text("please load a city!"),
                    //   behavior: SnackBarBehavior.floating, // Add this line
                    // ));
                  },
                  icon: const Icon(Icons.error, color: Colors.white, size: 35),
                );
              } else if (state.cwStatus is CwCompleted) {
                final CwCompleted cwCompleted = state.cwStatus as CwCompleted;
                final CurrentCityEntity currentCityEntity =
                    cwCompleted.currentCityEntity;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        currentCityEntity.name!,
                        style:
                            const TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        currentCityEntity.weather![0].description!,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: AppBackground.setIconForMain(
                          currentCityEntity.weather![0].description!,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        "${currentCityEntity.main!.temp!.round()}\u00B0",
                        style:
                            const TextStyle(fontSize: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    //min and max temp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// max temp
                        Column(
                          children: [
                            const Text(
                              "max",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${currentCityEntity.main!.tempMax!.round()}\u00B0",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        /// divider
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10,
                          ),
                          child: Container(
                            color: Colors.grey,
                            width: 2,
                            height: 40,
                          ),
                        ),

                        /// min temp
                        Column(
                          children: [
                            const Text(
                              "min",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${currentCityEntity.main!.tempMin!.round()}\u00B0",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(height: 2, width: width, color: Colors.grey),
                  ],
                );
              } else {
                return Container(
                  color: Colors.amber,
                );
              }
            },
          ),
        ),
      ],
    ),);
  }
}
