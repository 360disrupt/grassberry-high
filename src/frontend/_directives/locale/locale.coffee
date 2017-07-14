'use strict'
angular.module 'ngLocale', [], [
  '$provide'
  ($provide) ->
    PLURAL_CATEGORY =
      ZERO: 'zero'
      ONE: 'one'
      TWO: 'two'
      FEW: 'few'
      MANY: 'many'
      OTHER: 'other'

    getDecimals = (n) ->
      n = n + ''
      i = n.indexOf('.')
      if i == -1 then 0 else n.length - i - 1

    getVF = (n, opt_precision) ->
      v = opt_precision
      if undefined == v
        v = Math.min(getDecimals(n), 3)
      base = 10 ** v
      f = (n * base | 0) % base
      {
        v: v
        f: f
      }

    $provide.value '$locale',
      'DATETIME_FORMATS':
        'AMPMS': [
          'vorm.'
          'nachm.'
        ]
        'DAY': [
          'Sonntag'
          'Montag'
          'Dienstag'
          'Mittwoch'
          'Donnerstag'
          'Freitag'
          'Samstag'
        ]
        'ERANAMES': [
          'v. Chr.'
          'n. Chr.'
        ]
        'ERAS': [
          'v. Chr.'
          'n. Chr.'
        ]
        'FIRSTDAYOFWEEK': 0
        'MONTH': [
          'Januar'
          'Februar'
          'März'
          'April'
          'Mai'
          'Juni'
          'Juli'
          'August'
          'September'
          'Oktober'
          'November'
          'Dezember'
        ]
        'SHORTDAY': [
          'So.'
          'Mo.'
          'Di.'
          'Mi.'
          'Do.'
          'Fr.'
          'Sa.'
        ]
        'SHORTMONTH': [
          'Jan.'
          'Feb.'
          'März'
          'Apr.'
          'Mai'
          'Juni'
          'Juli'
          'Aug.'
          'Sep.'
          'Okt.'
          'Nov.'
          'Dez.'
        ]
        'STANDALONEMONTH': [
          'Januar'
          'Februar'
          'März'
          'April'
          'Mai'
          'Juni'
          'Juli'
          'August'
          'September'
          'Oktober'
          'November'
          'Dezember'
        ]
        'WEEKENDRANGE': [
          5
          6
        ]
        'fullDate': 'EEEE, d. MMMM y'
        'longDate': 'd. MMMM y'
        'medium': 'dd.MM.y HH:mm:ss'
        'mediumDate': 'dd.MM.y'
        'mediumTime': 'HH:mm:ss'
        'short': 'dd.MM.yy HH:mm'
        'shortDate': 'dd.MM.yy'
        'shortTime': 'HH:mm'
      'NUMBER_FORMATS':
        'CURRENCY_SYM': '€'
        'DECIMAL_SEP': ','
        'GROUP_SEP': '.'
        'PATTERNS': [
          {
            'gSize': 3
            'lgSize': 3
            'maxFrac': 3
            'minFrac': 0
            'minInt': 1
            'negPre': '-'
            'negSuf': ''
            'posPre': ''
            'posSuf': ''
          }
          {
            'gSize': 3
            'lgSize': 3
            'maxFrac': 2
            'minFrac': 2
            'minInt': 1
            'negPre': '-'
            'negSuf': ' ¤'
            'posPre': ''
            'posSuf': ' ¤'
          }
        ]
      'id': 'de-de'
      'pluralCat': (n, opt_precision) ->
        i = n | 0
        vf = getVF(n, opt_precision)
        if i == 1 and vf.v == 0
          return PLURAL_CATEGORY.ONE
        PLURAL_CATEGORY.OTHER
    return
]