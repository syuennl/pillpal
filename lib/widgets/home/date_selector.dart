import 'package:flutter/material.dart';
import 'package:pillpal/utils/app_colours.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateSelector({
    super.key,
    required this.selectedMonth,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late final ScrollController _scrollController;

  // how many days in tht month
  // month+1, day=0 gives last day of current month
  int get _itemCount => DateTime(
    widget.selectedMonth.year,
    widget.selectedMonth.month + 1,
    0,
  ).day;

  int get _selectedIndex => widget.selectedDate.day - 1;
  // widget = talk to the date selector widget and access its attr

  @override
  void initState() {
    // runs once screen created
    super.initState();
    _scrollController = ScrollController();
    _scrollToIndex(_selectedIndex, animate: false);
    // animate = for animation to scroll to date, if false, no animation, directly display scrolled to date
    // init put false so everytime screen rebuild, it won't re-scroll to the date
  }

  @override
  void didUpdateWidget(DateSelector oldWidget) {
    // when home's state chg, dis might nid to chg
    super.didUpdateWidget(
      oldWidget,
    ); // compare old and new widget to only update needed parts
    if (oldWidget.selectedMonth !=
            widget
                .selectedMonth || // if chged month (dropdown) or date (selector), then update
        oldWidget.selectedDate != widget.selectedDate) {
      // animate if same month, jump if new month
      bool shouldAnimate =
          oldWidget.selectedMonth.year ==
              widget
                  .selectedMonth
                  .year && // if only date chged, yr and month remain
          oldWidget.selectedMonth.month == widget.selectedMonth.month;
      _scrollToIndex(_selectedIndex, animate: shouldAnimate);
    }
  }

  void _scrollToIndex(int index, {bool animate = true}) {
    // animate = true default value
    // wait til screen renders frame 1 completely, cuz cant scroll if not rendered yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted)
        return; // check if widget still in tree/disposed (not abt rendering, e.g. user may have navigate to other screens)
      final double itemWidth = 68.0; // each item (date) size
      const double horizontalPadding =
          32.0; // 16.0 padding on left & right of screen

      // screen width - paddings (media query = screen info like w,h,padding)
      final double viewWidth =
          MediaQuery.of(context).size.width - horizontalPadding;

      double offset =
          (index * itemWidth) -
          (viewWidth / 2) +
          (itemWidth /
              2); // calc how far to scroll frm the left to center the selected date
      // position of item (left edge) - half of screen = how much to scroll to rch center
      // left edge of item in center, so + half item width so the center of item align to center of screen

      // prevent scrolling bfr the beginning or aft the end
      if (offset < 0) offset = 0;
      if (_scrollController.hasClients &&
          offset > _scrollController.position.maxScrollExtent) {
        // has clients ensure list view (dates) alr rendered
        offset = _scrollController.position.maxScrollExtent;
      }

      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _scrollController.jumpTo(offset);
        }
      }
    });
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, // so the drop shadow doesn't get cut off!
      child: ListView.builder(
        clipBehavior: Clip
            .none, // allows shadow to bleed outside list bounds, not clipped/cropped
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _itemCount,
        itemBuilder: (context, index) {
          // check if the current item (date) = selected date, every date gets their own bool
          bool isSelected = index == _selectedIndex;
          bool isNextToSelected =
              index == _selectedIndex - 1 || index == _selectedIndex + 1;

          DateTime date = DateTime(
            widget.selectedMonth.year,
            widget.selectedMonth.month,
            index + 1,
          ); // get date, x use index directly cuz e.g. tdy is 1/4, yesterday shuld be 31/3 not 0/4

          return GestureDetector(
            onTap: () {
              widget.onDateChanged(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColours.primaryGreen : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15, //10
                      offset: const Offset(0, 10), //0,4
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isNextToSelected
                          ? Colors.grey[600]
                          : Colors.grey[400], //888888
                      fontSize: 12, //10
                      fontWeight: FontWeight.w500, //medium
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isNextToSelected
                          ? Colors.grey[600]
                          : Colors.grey[400],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
