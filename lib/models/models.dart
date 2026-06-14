import '../core/json_utils.dart';

class Account {
  final String id, gameId, nickname, level, kingdom;
  final String? stoveLevel, furnaceTier, allianceTag, avatarImage;
  final String? stoveIcon, stoveColor, nextStoveIcon, nextStoveColor;
  final String? totalRecharge, status, isActive;

  Account({
    required this.id, required this.gameId, required this.nickname,
    required this.level, required this.kingdom,
    this.stoveLevel, this.furnaceTier, this.allianceTag, this.avatarImage,
    this.stoveIcon, this.stoveColor, this.nextStoveIcon, this.nextStoveColor,
    this.totalRecharge, this.status, this.isActive,
  });

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        id: j['id'] as String? ?? '',
        gameId: j['game_id'] as String? ?? '',
        nickname: j['nickname'] as String? ?? '',
        level: optStr(j, 'level') ?? '',
        kingdom: optStr(j, 'kingdom') ?? '',
        stoveLevel: optStr(j, 'stove_level'),
        furnaceTier: optStr(j, 'furnace_tier'),
        allianceTag: optStr(j, 'alliance_tag'),
        avatarImage: optStr(j, 'avatar_image'),
        stoveIcon: optStr(j, 'stove_icon'),
        stoveColor: optStr(j, 'stove_color'),
        nextStoveIcon: optStr(j, 'next_stove_icon'),
        nextStoveColor: optStr(j, 'next_stove_color'),
        totalRecharge: optStr(j, 'total_recharge'),
        status: optStr(j, 'status'),
        isActive: optStr(j, 'is_active'),
      );
}

class TransferPlayer {
  final String id, gameId, nickname, level, kingdom;
  final String? stoveLevel, furnaceTier, avatarImage, stoveColor;
  final String? nextStoveColor, status, notes, createdAt;

  TransferPlayer({
    required this.id, required this.gameId, required this.nickname,
    required this.level, required this.kingdom,
    this.stoveLevel, this.furnaceTier, this.avatarImage, this.stoveColor,
    this.nextStoveColor, this.status, this.notes, this.createdAt,
  });

  factory TransferPlayer.fromJson(Map<String, dynamic> j) => TransferPlayer(
        id: j['id'] as String? ?? '',
        gameId: j['game_id'] as String? ?? '',
        nickname: j['nickname'] as String? ?? '',
        level: optStr(j, 'level') ?? '',
        kingdom: optStr(j, 'kingdom') ?? '',
        stoveLevel: optStr(j, 'stove_level'),
        furnaceTier: optStr(j, 'furnace_tier'),
        avatarImage: optStr(j, 'avatar_image'),
        stoveColor: optStr(j, 'stove_color'),
        nextStoveColor: optStr(j, 'next_stove_color'),
        status: optStr(j, 'status'),
        notes: optStr(j, 'notes'),
        createdAt: optStr(j, 'created_at'),
      );
}

class GiftCode {
  final String id, code;
  final String? description, isActive, expiresAt;

  GiftCode({
    required this.id, required this.code,
    this.description, this.isActive, this.expiresAt,
  });

  factory GiftCode.fromJson(Map<String, dynamic> j) => GiftCode(
        id: j['id'] as String? ?? '',
        code: j['code'] as String? ?? '',
        description: optStr(j, 'description'),
        isActive: optStr(j, 'is_active'),
        expiresAt: optStr(j, 'expires_at'),
      );
}

class RedeemLog {
  final String? id, gameId, code, status, message, redeemedBy, createdAt;

  RedeemLog({this.id, this.gameId, this.code, this.status, this.message, this.redeemedBy, this.createdAt});

  factory RedeemLog.fromJson(Map<String, dynamic> j) => RedeemLog(
        id: optStr(j, 'id'),
        gameId: optStr(j, 'game_id'),
        code: optStr(j, 'code'),
        status: optStr(j, 'status'),
        message: optStr(j, 'message'),
        redeemedBy: optStr(j, 'redeemed_by'),
        createdAt: optStr(j, 'created_at'),
      );
}

class ActivityEntry {
  final String? id, action, details, createdAt;

  ActivityEntry({this.id, this.action, this.details, this.createdAt});

  factory ActivityEntry.fromJson(Map<String, dynamic> j) => ActivityEntry(
        id: optStr(j, 'id'),
        action: optStr(j, 'action'),
        details: optStr(j, 'details'),
        createdAt: optStr(j, 'created_at'),
      );
}

class Alliance {
  final String tag;
  final String? name, memberCount, kingdom;

  Alliance({required this.tag, this.name, this.memberCount, this.kingdom});

  factory Alliance.fromJson(Map<String, dynamic> j) => Alliance(
        tag: j['tag'] as String? ?? '',
        name: optStr(j, 'name'),
        memberCount: optStr(j, 'member_count'),
        kingdom: optStr(j, 'kingdom'),
      );
}
