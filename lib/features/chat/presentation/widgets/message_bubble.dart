import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String time;
  final String senderName;

  const MessageBubble({
    required this.content,
    required this.isMe,
    required this.time,
    required this.senderName,
    super.key,
  });

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.navyBlue
                        : (theme.brightness == Brightness.dark
                            ? Colors.grey[800]
                            : const Color(0xFFF2F4F8)),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomRight:
                          isMe ? Radius.circular(2.r) : Radius.circular(16.r),
                      bottomLeft:
                          isMe ? Radius.circular(16.r) : Radius.circular(2.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          offset: const Offset(0, 1),
                          blurRadius: 2),
                    ],
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    alignment: WrapAlignment.end,
                    children: [
                      Text(
                        content,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          color: isMe
                              ? Colors.white
                              : (theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : AppColors.textDark),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(time),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              color:
                                  isMe ? Colors.white70 : theme.disabledColor,
                            ),
                          ),
                          if (isMe) ...[
                            SizedBox(width: 4.w),
                            Icon(Icons.done_all,
                                size: 14.sp, color: Colors.white70),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
