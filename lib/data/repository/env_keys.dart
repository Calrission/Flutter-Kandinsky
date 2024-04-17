import 'package:env_flutter/env_flutter.dart';

Map<String, String> fetchHeadersTokens(){
  return {
    "X-Key": "Key ${dotenv.env['PUBLIC_KEY']}",
    "X-Secret": "Secret ${dotenv.env['SECRET_KEY']}"
  };
}