// ignore_for_file: file_names

import 'package:algolia/algolia.dart';

class AlgoliaApplication{
  static const Algolia algolia = Algolia.init(
    applicationId: 'QCPNFZZ951', //ApplicationID
    apiKey: 'c0984d379fb05a32f04170b2317d609f', //search-only api key in flutter code
  );
}