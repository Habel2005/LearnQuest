import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class FirebaseMessage {
  static Future<String> getAccessToken() async {
    final serviceAccountjson = {
      "type": "service_account",
      "project_id": "skillswap-7fd3a",
      "private_key_id": "2006ac6b770b3bc8298e36d6e12738853994f27f",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCngjEGv+HDZAUF\nggF0MeWgWfxKbKR9ILxuJyT7R9G4hlPEYgeeyxFnV5Yt9wRIxXEXHEohTHu61FUL\ngBqbH7IszGFqbJY5cPcQSKK0nxmITUY74wsxIXVQUNjRR3z02A4I4uKeQNrh+mpg\n6WdaRHhtZs3m+52vY9G57fY+nta4UbQWCldI8KjBD5VXM4pkwXe/SgxlocOvvn1G\nzLr6Szl1GGlnOfWZP1shBP/lvUBLgO1lU50AnI2h8pheVvGsST+HtkvcGwdM7E4/\nlKEcoWuiQ2m4xVIeJlUjQ5XX71sIg/T+6Z7bsTAUYDWtQKoKE1XLmEKUrtoTn4Qh\nTmUvXtjJAgMBAAECggEAB7x2zK/AesBsDfLQ49+pEgSN5xcI6sGACltS9Sr+N9Y2\nWK/JV89bnKj6JeHOaBj8Tduv3cVVQo3rZpZSRD9MwI5o4lwk/P6nXnBoWUyuxnGB\nMKNeATUhIKY3OUUis4El9smZu0LWCRFCZ/rnm87lO/I/SK9uuyqyRTLFCGPYGVeT\nh0MtI4pdyiXRC5q7A4BeqeTCcKXIlbHPrN4jJLQizmZ89bG7rlM15Tm/bxfYNLHE\nlPrrCeQ8OnRThQ5wC/VGmwzWyFr1gNyJXCQ2zKkcap04PN8COv3rvaaDIIjT1fuL\npm9qiaexeqN6j/SNcEkdTYqYQqS+fi+rz7H00Qx0/QKBgQDRukSN7NOoqXX2WyUj\n8sPobg4L1LZtHegXvcnQWSaYpX8oQi8AsHq6/JVwzMEEx3WPQjMH00eXT1o6fsrz\nmVsfKtXs+zp1PxQ2pXdeh7VvR6jZsiS/R74Xj0oNs46KAgpD3Hx0MoJlVn3TgcT4\nO4h6sZS7tjAxarfwQ/up436lJQKBgQDMd1P+X2PpyIJzfxadkj8CmPwziGvbkoB0\nPKGQoSln8xNrdg2nEgJ0lubNVxXK2mF8/NWEYhCiG6gJg/OCN3DsNpvq/RBepSci\nQ9vCLhTEfdHIv+tap+A3sZksM1pAXmJhD49GhhAZel9f3uMUlnuqmnofpCfpTiiO\nRcF8r61d1QKBgHmpto8mbXqQI7AwG5GJCQDSpy9RzCnsiXEMVgCZVvyCNQujqSSb\nO/cxA3gWL3qYQqhCXNwTQpqSG+OHHjDGK8gez07URosxdoZk4qRh0Wymg1sWLp8P\n/UQpiWn9WZjRqibHxyKZEm+7Bu8lfqAJ2Rhj38Ys4DQqll248ksRf6xJAoGAGSFl\ngnNI/Xf2iKmLJwzNj80r2k2fLBqijSbSmMsmIq+eqGuXG/y7robJkV1twUP8DXep\n6p5++t25VooQSOX1jCLeIRC/jVJxL+X1QbWWOdxZB3qHO9o8VbwPXn5lTloLb3CR\nJJLfsbH3vPnRITupsXtRHUh421UO6QWr1V5mSY0CgYA3KC/g0OzzYOHBXz/wEuB6\n330L5cifwSRN8o46zqBmDBmlco9Xk/lg9R8C3jt183ICtVdB2lebLRAx5AoAE4tR\nSdimkoS6/zoHcLlzs1KvtoRgncsEtTHO2AS9fQXNQSqqNKF+zT+nQpL54DcWsdsh\nm92j5RryOiLYxb/v+qtKDg==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "flutter-learnquest-service-acc@skillswap-7fd3a.iam.gserviceaccount.com",
      "client_id": "105465183689257385366",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-learnquest-service-acc%40skillswap-7fd3a.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountjson), scopes);

    //get access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountjson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  static Future<void> sendNotificationForLikes(
      {required String deviceToken,
      required String commentExcerpt,
      required String postId}) async {
    final String serviceKey = await getAccessToken();

    String endpoint =
        'https://fcm.googleapis.com/v1/projects/skillswap-7fd3a/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': 'Your Post Got a Like!',
          'body': commentExcerpt,
        },
        'data': {
          'post': postId,
        },
      }
    };

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $serviceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully");
    } else {
      print("Failed to send notification: ${response.body}");
    }
  }
}
