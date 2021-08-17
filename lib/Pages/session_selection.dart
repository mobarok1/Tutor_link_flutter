import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/session_model.dart';
import 'package:tutorlink/modelView/filter_sort_by_page.dart';

class SessionSelect extends StatelessWidget {
  final CallBackWith1 onSessionSelect;
  final List<SessionModel> sessions;
  SessionSelect({this.onSessionSelect,this.sessions});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a Session"),
      ),
      body: Column(
        children: [
          Flexible(
              child: SfCalendar(
                view: CalendarView.schedule,
                showDatePickerButton: true,
                headerStyle: CalendarHeaderStyle(),
                dataSource: SessionDataSource(sessions),
                // by default the month appointment display mode set as Indicator, we can
                // change the display mode as appointment using the appointment display
                // mode property
                scheduleViewSettings: ScheduleViewSettings(
                  appointmentTextStyle: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                appointmentBuilder: (ctx,CalendarAppointmentDetails details){
                  return Container(
                    child: FlatButton(
                        padding: EdgeInsets.only(left: 0,right: 0,top: 0,bottom: 0),
                        color: appsMainColor,
                        textColor: Colors.white,
                        onPressed: (){
                          print(details.appointments.cast().first.uuId);
                        },
                        child: Text("From ${DateFormat("hh:mm").format(details.appointments.cast().first.startDate)} to ${DateFormat("hh:mm").format(details.appointments.cast().first.endDate)}")
                    ),
                  );
                },
                firstDayOfWeek: 1,
                onTap: (CalendarTapDetails details){
                  print(details.appointments.cast().first.uuId);
                  onSessionSelect(details.appointments.cast().first);
                  Navigator.pop(context);
                },
                monthViewSettings: MonthViewSettings(
                  showAgenda: true,
                  agendaItemHeight: 100,
                  numberOfWeeksInView: 5,
                  dayFormat: 'E',
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  showTrailingAndLeadingDates: true,
                  monthCellStyle: MonthCellStyle(
                    leadingDatesBackgroundColor: Colors.grey.withOpacity(.2),
                    leadingDatesTextStyle: TextStyle(color: Colors.grey.withOpacity(.5)),

                  ),
                ),
                timeSlotViewSettings: TimeSlotViewSettings(
                    startHour: 0,
                    endHour: 0
                ),
              )
          )
        ],
      ),
    );
  }
}
class SessionDataSource extends CalendarDataSource {
  SessionDataSource(List<SessionModel> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].endDate;
  }

  @override
  String getSubject(int index) {
    return appointments[index].uuId;
  }

  @override
  Color getColor(int index) {
    return Colors.green;
  }

  @override
  bool isAllDay(int index) {
    //  return appointments[index].isAllDay;
    return true;
  }
}
