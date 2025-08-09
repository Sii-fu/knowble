import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final Color color;
  final double size;

  const CustomIconWidget({
    super.key,
    required this.iconName,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Map icon names to Icons
    IconData? iconData;
    switch (iconName) {
      case 'arrow_forward':
        iconData = Icons.arrow_forward;
        break;
      case 'arrow_back':
        iconData = Icons.arrow_back;
        break;
      case 'check':
        iconData = Icons.check;
        break;
      case 'close':
        iconData = Icons.close;
        break;
      case 'home':
        iconData = Icons.home;
        break;
      case 'person':
        iconData = Icons.person;
        break;
      case 'school':
        iconData = Icons.school;
        break;
      case 'settings':
        iconData = Icons.settings;
        break;
      case 'search':
        iconData = Icons.search;
        break;
      case 'notifications':
        iconData = Icons.notifications;
        break;
      case 'notifications_none':
        iconData = Icons.notifications_none;
        break;
      case 'mark_email_read':
        iconData = Icons.mark_email_read;
        break;
      case 'delete_outline':
        iconData = Icons.delete_outline;
        break;
      case 'dashboard':
        iconData = Icons.dashboard;
        break;
      case 'people':
        iconData = Icons.people;
        break;
      case 'book':
        iconData = Icons.book;
        break;
      case 'logout':
        iconData = Icons.logout;
        break;
      case 'verified_user':
        iconData = Icons.verified_user;
        break;
      case 'manage_accounts':
        iconData = Icons.manage_accounts;
        break;
      case 'analytics':
        iconData = Icons.analytics;
        break;
      case 'pending_actions':
        iconData = Icons.pending_actions;
        break;
      case 'report':
        iconData = Icons.report;
        break;
      case 'check_circle':
        iconData = Icons.check_circle;
        break;
      case 'cancel':
        iconData = Icons.cancel;
        break;
      case 'visibility':
        iconData = Icons.visibility;
        break;
      case 'visibility_off':
        iconData = Icons.visibility_off;
        break;
      case 'clear':
        iconData = Icons.clear;
        break;
      case 'edit':
        iconData = Icons.edit;
        break;
      case 'people_outline':
        iconData = Icons.people_outline;
        break;
      case 'checklist':
        iconData = Icons.checklist;
        break;
      case 'school_outlined':
        iconData = Icons.school_outlined;
        break;
      case 'filter_list':
        iconData = Icons.filter_list;
        break;
      case 'trending_up':
        iconData = Icons.trending_up;
        break;
      case 'trending_down':
        iconData = Icons.trending_down;
        break;
      case 'access_time':
        iconData = Icons.access_time;
        break;
      case 'chevron_right':
        iconData = Icons.chevron_right;
        break;
      case 'schedule':
        iconData = Icons.schedule;
        break;
      case 'work':
        iconData = Icons.work;
        break;
      case 'description':
        iconData = Icons.description;
        break;
      case 'feedback':
        iconData = Icons.feedback;
        break;
      case 'person_add':
        iconData = Icons.person_add;
        break;
      case 'flag':
        iconData = Icons.flag;
        break;
      case 'favorite':
        iconData = Icons.favorite;
        break;
      case 'share':
        iconData = Icons.share;
        break;
      case 'download':
        iconData = Icons.download;
        break;
      case 'play_arrow':
        iconData = Icons.play_arrow;
        break;
      case 'pause':
        iconData = Icons.pause;
        break;
      case 'stop':
        iconData = Icons.stop;
        break;
      case 'skip_next':
        iconData = Icons.skip_next;
        break;
      case 'skip_previous':
        iconData = Icons.skip_previous;
        break;
      case 'volume_up':
        iconData = Icons.volume_up;
        break;
      case 'volume_down':
        iconData = Icons.volume_down;
        break;
      case 'volume_off':
        iconData = Icons.volume_off;
        break;
      case 'fullscreen':
        iconData = Icons.fullscreen;
        break;
      case 'fullscreen_exit':
        iconData = Icons.fullscreen_exit;
        break;
      case 'subtitles':
        iconData = Icons.subtitles;
        break;
      case 'closed_caption':
        iconData = Icons.closed_caption;
        break;
      case 'high_quality':
        iconData = Icons.high_quality;
        break;
      case 'speed':
        iconData = Icons.speed;
        break;
      case 'replay':
        iconData = Icons.replay;
        break;
      case 'replay_10':
        iconData = Icons.replay_10;
        break;
      case 'forward_10':
        iconData = Icons.forward_10;
        break;
      case 'replay_30':
        iconData = Icons.replay_30;
        break;
      case 'forward_30':
        iconData = Icons.forward_30;
        break;
      case 'replay_5':
        iconData = Icons.replay_5;
        break;
      case 'forward_5':
        iconData = Icons.forward_5;
        break;
      case 'error_outline':
        iconData = Icons.error_outline;
        break;
      case 'keyboard_arrow_down':
        iconData = Icons.keyboard_arrow_down;
        break;
      case 'info_outline':
        iconData = Icons.info_outline;
        break;
      case 'refresh':
        iconData = Icons.refresh;
        break;
      default:
        iconData = Icons.help_outline; // Default icon
    }

    return Icon(iconData, color: color, size: size);
  }
}
