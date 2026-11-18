import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

/// One icon of the set: its glyph, and whether it flips in right-to-left
/// text (arrows and chevrons that point along the reading direction).
@immutable
class TfIconData {
  const TfIconData(this.glyph, {this.mirrorsInRtl = false});

  final IconData glyph;
  final bool mirrorsInRtl;
}

/// The only place icons are named. Screens use `TfIcons.x`, never `Icons.*`.
abstract final class TfIcons {
  static const check = TfIconData(LucideIcons.check);
  static const close = TfIconData(LucideIcons.x);
  static const plus = TfIconData(LucideIcons.plus);
  static const minus = TfIconData(LucideIcons.minus);
  static const search = TfIconData(LucideIcons.search);
  static const more = TfIconData(LucideIcons.ellipsis);
  static const menu = TfIconData(LucideIcons.menu);
  static const chevronDown = TfIconData(LucideIcons.chevronDown);
  static const chevronUp = TfIconData(LucideIcons.chevronUp);
  static const chevronStart = TfIconData(
    LucideIcons.chevronLeft,
    mirrorsInRtl: true,
  );
  static const chevronEnd = TfIconData(
    LucideIcons.chevronRight,
    mirrorsInRtl: true,
  );
  static const arrowStart = TfIconData(
    LucideIcons.arrowLeft,
    mirrorsInRtl: true,
  );
  static const arrowEnd = TfIconData(
    LucideIcons.arrowRight,
    mirrorsInRtl: true,
  );
  static const arrowUp = TfIconData(LucideIcons.arrowUp);
  static const arrowDown = TfIconData(LucideIcons.arrowDown);
  static const sort = TfIconData(LucideIcons.arrowUpDown);
  static const filter = TfIconData(LucideIcons.listFilter);
  static const info = TfIconData(LucideIcons.info);
  static const warning = TfIconData(LucideIcons.triangleAlert);
  static const error = TfIconData(LucideIcons.circleAlert);
  static const success = TfIconData(LucideIcons.circleCheck);
  static const cancel = TfIconData(LucideIcons.circleX);
  static const todo = TfIconData(LucideIcons.circleDashed);
  static const active = TfIconData(LucideIcons.circleDot);
  static const done = TfIconData(LucideIcons.circleCheck);
  static const blocked = TfIconData(LucideIcons.ban);
  static const flag = TfIconData(LucideIcons.flag);
  static const priorityUrgent = TfIconData(LucideIcons.chevronsUp);
  static const priorityHigh = TfIconData(LucideIcons.chevronUp);
  static const priorityNormal = TfIconData(LucideIcons.equal);
  static const priorityLow = TfIconData(LucideIcons.chevronDown);
  static const priorityNone = TfIconData(LucideIcons.minus);
  static const calendar = TfIconData(LucideIcons.calendar);
  static const calendarDays = TfIconData(LucideIcons.calendarDays);
  static const clock = TfIconData(LucideIcons.clock);
  static const user = TfIconData(LucideIcons.user);
  static const users = TfIconData(LucideIcons.users);
  static const settings = TfIconData(LucideIcons.settings);
  static const trash = TfIconData(LucideIcons.trash2);
  static const edit = TfIconData(LucideIcons.pencil);
  static const copy = TfIconData(LucideIcons.copy);
  static const link = TfIconData(LucideIcons.link);
  static const externalLink = TfIconData(LucideIcons.externalLink);
  static const attachment = TfIconData(LucideIcons.paperclip);
  static const send = TfIconData(LucideIcons.send, mirrorsInRtl: true);
  static const bell = TfIconData(LucideIcons.bell);
  static const star = TfIconData(LucideIcons.star);
  static const undo = TfIconData(LucideIcons.undo2, mirrorsInRtl: true);
  static const eye = TfIconData(LucideIcons.eye);
  static const lock = TfIconData(LucideIcons.lock);
  static const sun = TfIconData(LucideIcons.sun);
  static const moon = TfIconData(LucideIcons.moon);
  static const keyboard = TfIconData(LucideIcons.keyboard);
  static const list = TfIconData(LucideIcons.list);
  static const board = TfIconData(LucideIcons.squareKanban);
  static const columns = TfIconData(LucideIcons.columns3);
  static const timeline = TfIconData(LucideIcons.chartGantt);
  static const dashboard = TfIconData(LucideIcons.layoutDashboard);
  static const inbox = TfIconData(LucideIcons.inbox);
  static const home = TfIconData(LucideIcons.house);
  static const chat = TfIconData(LucideIcons.messageSquare);
  static const folder = TfIconData(LucideIcons.folder);
  static const file = TfIconData(LucideIcons.file);
  static const image = TfIconData(LucideIcons.image);
  static const tag = TfIconData(LucideIcons.tag);
  static const target = TfIconData(LucideIcons.target);
  static const bolt = TfIconData(LucideIcons.zap);
  static const hash = TfIconData(LucideIcons.hash);
  static const download = TfIconData(LucideIcons.download);
  static const upload = TfIconData(LucideIcons.upload);
  static const refresh = TfIconData(LucideIcons.refreshCw);
  static const sidebar = TfIconData(LucideIcons.panelLeft, mirrorsInRtl: true);
  static const signOut = TfIconData(LucideIcons.logOut, mirrorsInRtl: true);
  static const smile = TfIconData(LucideIcons.smile);
  static const circle = TfIconData(LucideIcons.circle);
  static const chart = TfIconData(LucideIcons.chartColumn);
  static const form = TfIconData(LucideIcons.clipboardList);
  static const shield = TfIconData(LucideIcons.shieldCheck);
  static const history = TfIconData(LucideIcons.history);
  static const code = TfIconData(LucideIcons.code);
  static const server = TfIconData(LucideIcons.server);
  static const archive = TfIconData(LucideIcons.archive);
  static const globe = TfIconData(LucideIcons.globe);
  static const devices = TfIconData(LucideIcons.monitorSmartphone);
  static const cloudOff = TfIconData(LucideIcons.cloudOff);
  static const wifi = TfIconData(LucideIcons.wifi);
  static const palette = TfIconData(LucideIcons.palette);
  static const help = TfIconData(LucideIcons.circleHelp);
  static const grip = TfIconData(LucideIcons.gripVertical);
  static const tune = TfIconData(LucideIcons.slidersHorizontal);
  static const chatPlus = TfIconData(LucideIcons.messageSquarePlus);
  static const checkAll = TfIconData(LucideIcons.checkCheck);
  static const key = TfIconData(LucideIcons.keyRound);
  static const activity = TfIconData(LucideIcons.activity);
  static const workflow = TfIconData(LucideIcons.workflow);

  static const moreVertical = TfIconData(LucideIcons.ellipsisVertical);
  static const expandAll = TfIconData(LucideIcons.chevronsUpDown);
  static const collapseAll = TfIconData(LucideIcons.chevronsDownUp);
  static const calendarEdit = TfIconData(LucideIcons.calendarCog);
  static const repeat = TfIconData(LucideIcons.repeat);
  static const calendarCheck = TfIconData(LucideIcons.calendarCheck);
  static const calendarRange = TfIconData(LucideIcons.calendarRange);
  static const calendarX = TfIconData(LucideIcons.calendarX);
  static const userPlus = TfIconData(LucideIcons.userPlus);
  static const bookmark = TfIconData(LucideIcons.bookmark);
  static const rows = TfIconData(LucideIcons.rows3);
  static const pin = TfIconData(LucideIcons.pin);
  static const pinOff = TfIconData(LucideIcons.pinOff);
  static const camera = TfIconData(LucideIcons.camera);
  static const images = TfIconData(LucideIcons.images);
  static const clipboardPaste = TfIconData(LucideIcons.clipboardPaste);
  static const video = TfIconData(LucideIcons.video);
  static const fileText = TfIconData(LucideIcons.fileText);
  static const pause = TfIconData(LucideIcons.pause);
  static const play = TfIconData(LucideIcons.play);
  static const bot = TfIconData(LucideIcons.bot);
  static const layers = TfIconData(LucideIcons.layers);
  static const eyeOff = TfIconData(LucideIcons.eyeOff);
  static const bellOff = TfIconData(LucideIcons.bellOff);
  static const arrowLeftRight = TfIconData(LucideIcons.arrowLeftRight);
  static const timer = TfIconData(LucideIcons.timer);
  static const quote = TfIconData(LucideIcons.quote);
  static const maximize = TfIconData(LucideIcons.maximize2);
  static const webhook = TfIconData(LucideIcons.webhook);
  static const unlink = TfIconData(LucideIcons.unlink);
  static const share = TfIconData(LucideIcons.share2);
  static const puzzle = TfIconData(LucideIcons.puzzle);
  static const filePlus = TfIconData(LucideIcons.filePlus);
  static const alignLeft = TfIconData(LucideIcons.alignLeft);
  static const heading = TfIconData(LucideIcons.heading);
  static const listOrdered = TfIconData(LucideIcons.listOrdered);
  static const listChecks = TfIconData(LucideIcons.listChecks);
  static const table = TfIconData(LucideIcons.table);
  static const textType = TfIconData(LucideIcons.type);
  static const squareCheck = TfIconData(LucideIcons.squareCheck);
  static const dollarSign = TfIconData(LucideIcons.dollarSign);
  static const bold = TfIconData(LucideIcons.bold);
  static const italic = TfIconData(LucideIcons.italic);
  static const strikethrough = TfIconData(LucideIcons.strikethrough);
  static const folderPlus = TfIconData(LucideIcons.folderPlus);
  static const cornerDownRight = TfIconData(
    LucideIcons.cornerDownRight,
    mirrorsInRtl: true,
  );
  static const userMinus = TfIconData(LucideIcons.userMinus);
  static const smartphone = TfIconData(LucideIcons.smartphone);
  static const arrowUpToLine = TfIconData(LucideIcons.arrowUpToLine);
  static const circleStop = TfIconData(LucideIcons.circleStop);
  static const stop = TfIconData(LucideIcons.square);
  static const snooze = TfIconData(LucideIcons.alarmClock);
  static const circlePause = TfIconData(LucideIcons.circlePause);
  static const mail = TfIconData(LucideIcons.mail);
  static const command = TfIconData(LucideIcons.command);
  static const idCard = TfIconData(LucideIcons.idCard);
  static const atSign = TfIconData(LucideIcons.atSign);
  static const network = TfIconData(LucideIcons.network);

  /// Every icon, by name, for the gallery and the completeness test.
  static const all = <String, TfIconData>{
    'check': check,
    'close': close,
    'plus': plus,
    'minus': minus,
    'search': search,
    'more': more,
    'menu': menu,
    'chevronDown': chevronDown,
    'chevronUp': chevronUp,
    'chevronStart': chevronStart,
    'chevronEnd': chevronEnd,
    'arrowStart': arrowStart,
    'arrowEnd': arrowEnd,
    'arrowUp': arrowUp,
    'arrowDown': arrowDown,
    'sort': sort,
    'filter': filter,
    'info': info,
    'warning': warning,
    'error': error,
    'success': success,
    'cancel': cancel,
    'todo': todo,
    'active': active,
    'done': done,
    'blocked': blocked,
    'flag': flag,
    'priorityUrgent': priorityUrgent,
    'priorityHigh': priorityHigh,
    'priorityNormal': priorityNormal,
    'priorityLow': priorityLow,
    'priorityNone': priorityNone,
    'calendar': calendar,
    'calendarDays': calendarDays,
    'clock': clock,
    'user': user,
    'users': users,
    'settings': settings,
    'trash': trash,
    'edit': edit,
    'copy': copy,
    'link': link,
    'externalLink': externalLink,
    'attachment': attachment,
    'send': send,
    'bell': bell,
    'star': star,
    'undo': undo,
    'eye': eye,
    'lock': lock,
    'sun': sun,
    'moon': moon,
    'keyboard': keyboard,
    'list': list,
    'board': board,
    'columns': columns,
    'timeline': timeline,
    'dashboard': dashboard,
    'inbox': inbox,
    'home': home,
    'chat': chat,
    'folder': folder,
    'file': file,
    'image': image,
    'tag': tag,
    'target': target,
    'bolt': bolt,
    'hash': hash,
    'download': download,
    'upload': upload,
    'refresh': refresh,
    'sidebar': sidebar,
    'signOut': signOut,
    'smile': smile,
    'circle': circle,
    'chart': chart,
    'form': form,
    'shield': shield,
    'history': history,
    'code': code,
    'server': server,
    'archive': archive,
    'globe': globe,
    'devices': devices,
    'cloudOff': cloudOff,
    'wifi': wifi,
    'palette': palette,
    'help': help,
    'grip': grip,
    'tune': tune,
    'chatPlus': chatPlus,
    'checkAll': checkAll,
    'key': key,
    'activity': activity,
    'workflow': workflow,
    'moreVertical': moreVertical,
    'expandAll': expandAll,
    'collapseAll': collapseAll,
    'calendarEdit': calendarEdit,
    'repeat': repeat,
    'calendarCheck': calendarCheck,
    'calendarRange': calendarRange,
    'calendarX': calendarX,
    'userPlus': userPlus,
    'bookmark': bookmark,
    'rows': rows,
    'pin': pin,
    'pinOff': pinOff,
    'camera': camera,
    'images': images,
    'clipboardPaste': clipboardPaste,
    'video': video,
    'fileText': fileText,
    'pause': pause,
    'play': play,
    'bot': bot,
    'layers': layers,
    'eyeOff': eyeOff,
    'bellOff': bellOff,
    'arrowLeftRight': arrowLeftRight,
    'timer': timer,
    'quote': quote,
    'maximize': maximize,
    'webhook': webhook,
    'unlink': unlink,
    'share': share,
    'puzzle': puzzle,
    'filePlus': filePlus,
    'alignLeft': alignLeft,
    'heading': heading,
    'listOrdered': listOrdered,
    'listChecks': listChecks,
    'table': table,
    'textType': textType,
    'squareCheck': squareCheck,
    'dollarSign': dollarSign,
    'bold': bold,
    'italic': italic,
    'strikethrough': strikethrough,
    'folderPlus': folderPlus,
    'cornerDownRight': cornerDownRight,
    'userMinus': userMinus,
    'smartphone': smartphone,
    'arrowUpToLine': arrowUpToLine,
    'circleStop': circleStop,
    'stop': stop,
    'snooze': snooze,
    'circlePause': circlePause,
    'mail': mail,
    'command': command,
    'idCard': idCard,
    'atSign': atSign,
    'network': network,
  };
}

/// Draws a [TfIconData] in the text colour, mirrored in right-to-left when
/// the icon says so. Decorative unless [semanticLabel] is given.
/// Icon sizes. A bare [TfIcon] is [inline] (16): beside text, in Tf*
/// components. Inside Material controls that bring their own 40-48 px target
/// (IconButton, ListTile leading, input affixes) use [control].
abstract final class TfIconSize {
  static const double inline = 16;
  static const double control = 20;
}

class TfIcon extends StatelessWidget {
  const TfIcon(
    this.icon, {
    super.key,
    this.size = TfIconSize.inline,
    this.color,
    this.semanticLabel,
  });

  final TfIconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final glyph = Icon(
      icon.glyph,
      size: size,
      color: color ?? IconTheme.of(context).color,
      semanticLabel: semanticLabel,
    );
    return icon.mirrorsInRtl && rtl
        ? Transform.flip(flipX: true, child: glyph)
        : glyph;
  }
}
