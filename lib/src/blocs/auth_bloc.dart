import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:duuit/src/models/access_token.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:duuit/amplifyconfiguration.dart';
import 'package:rxdart/rxdart.dart';

class AuthBloc {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  final _accessTokenFetcher = PublishSubject<AccessToken>();

  AuthBloc() {
    // _configureAmplify();
  }

  Stream<AccessToken> get accessToken => _accessTokenFetcher.stream;

  loginWithFb() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        print('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');

        _accessTokenFetcher.add(AccessToken.fromFBAccessToken(result.accessToken));
        break;
      case FacebookLoginStatus.cancelledByUser:
        _accessTokenFetcher.addError('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');

        _accessTokenFetcher.addError('Unable to login, encountered error');
        break;
    }
  }

  void _configureAmplify() async {
    // AmplifyAnalyticsPinpoint analyticsPlugin = AmplifyAnalyticsPinpoint();
    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    if (!Amplify.isConfigured) {
      Amplify.addPlugins([
        authPlugin,
        // analyticsPlugin,
      ]);
      await Amplify.configure(amplifyconfig);
    }
  }

  dispose() {
    _accessTokenFetcher.close();
  }
}
