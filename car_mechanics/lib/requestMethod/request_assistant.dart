import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpRespone = await http.get(Uri.parse(url));

    try {
      if (httpRespone.statusCode == 200) {
        String responseData = httpRespone.body;
        var decodeResponseData = jsonDecode(responseData);

        return decodeResponseData;
      } else {
        return "Error Occured, Failed No Response...";
      }
    } catch (e) {
      return "Error Occured, Failed No Response...";
    }
  }
}
