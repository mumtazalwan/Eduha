import 'package:eduha/common/color_values.dart';
import 'package:eduha/model/detail_course.dart';
import 'package:eduha/model/material.dart';
import 'package:eduha/service/api-service.dart';
import 'package:eduha/service/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LessonView extends StatefulWidget {
  final String learningPath, course, lesson;
  final int id;

  const LessonView(
      {Key? key,
      required this.id,
      required this.learningPath,
      required this.course,
      required this.lesson})
      : super(key: key);

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  MaterialModel? _model;
  bool _isLoaded = false;
  final _controller = PageController();
  double _progress = 0;
  int _indicatorProgress = 0;

  Future _getApi() async {
    _model = await ApiService().getMaterial(widget.id);
    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getApi();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1.5,
        title: LinearPercentIndicator(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          backgroundColor: const Color(0XFFc0c0c0),
          progressColor: ColorValues.green,
          lineHeight: 7,
          percent: _progress,
          animation: true,
          animateFromLastPercent: true,
          barRadius: const Radius.circular(3),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: Row(
              children: [
                Text(
                  '1',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.flash_on_outlined,
                  color: Colors.amber,
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoaded
          ? _indicatorProgress == 0
              ? PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _model?.courseFoundation.length,
                  itemBuilder: (_, index) {
                    var model = _model!.courseFoundation[index];

                    return SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 20.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.material,
                              style: theme.headline1,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              model.explanation,
                              style: theme.bodyText1,
                            ),
                            SizedBox(
                              height: 25.h,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black,
                                minimumSize: Size(50.w, 40.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: (index ==
                                      _model!.courseFoundation.length - 1)
                                  ? () async {
                                      if (_indicatorProgress == 0) {
                                        setState(() {
                                          _indicatorProgress += 1;
                                          _progress += 1 /
                                              _model!.courseFoundation.length
                                                  .toDouble();
                                        });

                                        await FirebaseService()
                                            .saveProgressCourse(
                                            widget.learningPath,
                                            widget.course,
                                            'course',
                                            widget.lesson,
                                            index,
                                            _progress);
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    }
                                  : () async {
                                      setState(() {
                                        _progress += 1 /
                                            _model!.courseFoundation.length
                                                .toDouble();
                                      });

                                      await FirebaseService()
                                          .saveProgressCourse(
                                              widget.learningPath,
                                              widget.course,
                                              'course',
                                              widget.lesson,
                                              index,
                                              _progress);

                                      _controller.nextPage(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                              child: const Text('Continue'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Congratulation you have been finish this session',
                          style: theme.headline2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Lottie.asset('assets/lottie/finish.json',
                            height: 280.h),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          minimumSize: Size(50.w, 40.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Finish'),
                      ),
                    ],
                  ),
                )
          : Center(
              child: Lottie.asset('assets/lottie/cubes_loader.json',
                  height: 200.h),
            ),
    );
  }
}
