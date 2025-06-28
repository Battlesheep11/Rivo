import 'package:flutter/material.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';

class TagEntity {
  final String name;

  const TagEntity({required this.name});

  String localizedLabel(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final key = 'tag_${name.toLowerCase().replaceAll(' ', '_')}';

    switch (key) {
      case 'tag_vintage':
        return t.tagVintage;
      case 'tag_minimalism':
        return t.tagMinimalism;
      case 'tag_streetwear':
        return t.tagStreetwear;
      case 'tag_urban':
        return t.tagUrban;
      case 'tag_secondhand':
        return t.tagSecondhand;
      case 'tag_sustainable':
        return t.tagSustainable;
      case 'tag_colorful':
        return t.tagColorful;
      case 'tag_retro':
        return t.tagRetro;
      case 'tag_y2k':
        return t.tagY2k;
      case 'tag_oversized':
        return t.tagOversized;
      case 'tag_clean':
        return t.tagClean;
      case 'tag_ethical':
        return t.tagEthical;
      case 'tag_handmade':
        return t.tagHandmade;
      case 'tag_festival':
        return t.tagFestival;
      case 'tag_school':
        return t.tagSchool;
      case 'tag_office':
        return t.tagOffice;
      case 'tag_date_night':
        return t.tagDateNight;
      case 'tag_local_brands':
        return t.tagLocalBrands;
      default:
        return name;
    }
  }

  static const List<TagEntity> predefinedTags = [
    TagEntity(name: 'Vintage'),
    TagEntity(name: 'Minimalism'),
    TagEntity(name: 'Streetwear'),
    TagEntity(name: 'Urban'),
    TagEntity(name: 'Secondhand'),
    TagEntity(name: 'Sustainable'),
    TagEntity(name: 'Colorful'),
    TagEntity(name: 'Retro'),
    TagEntity(name: 'Y2K'),
    TagEntity(name: 'Oversized'),
    TagEntity(name: 'Clean'),
    TagEntity(name: 'Ethical'),
    TagEntity(name: 'Handmade'),
    TagEntity(name: 'Festival'),
    TagEntity(name: 'School'),
    TagEntity(name: 'Office'),
    TagEntity(name: 'Date Night'),
    TagEntity(name: 'Local Brands'),
  ];
}
