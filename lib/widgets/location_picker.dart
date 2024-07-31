import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/providers/place.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  WebViewController? _controller;
  geo.Position? _currentPosition;

  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _loadHtmlFromAssets();
    });
  }

  void _loadHtmlFromAssets() {
    if (_currentPosition != null) {
      final kakaoJsApiKey = dotenv.get("KAKAO_JS_KEY");
      String html = '''
        <!DOCTYPE html>
        <html>

        <head>
            <meta charset="utf-8" />
            <title>Kakao 지도 시작하기</title>
            <style>
              html, body {
                  height: 100%;
                  margin: 0;
                  padding: 0;
              }
              #map {
                  width: 100%;
                  height: 100%;
              }
          </style>
        </head>

        <body>
            <div id="map" style="width:100%;height:100%;"></div>
            <script type="text/javascript"
                src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoJsApiKey}"></script>
            <script>
                var container = document.getElementById('map');
                var options = {
                    center: new kakao.maps.LatLng(${_currentPosition!.latitude}, ${_currentPosition!.longitude}),
                    level: 2
                };
                var map = new kakao.maps.Map(container, options);

                var marker = new kakao.maps.Marker({
                    position: new kakao.maps.LatLng(${_currentPosition!.latitude}, ${_currentPosition!.longitude}),
                    draggable: true
                });
                marker.setMap(map);

                // 지도 클릭 이벤트를 추가하여 마커를 클릭한 위치로 이동시키기
                kakao.maps.event.addListener(map, 'click', function(mouseEvent) {
                    var latlng = mouseEvent.latLng; // 클릭한 위치의 좌표
                    marker.setPosition(latlng); // 마커의 위치를 클릭한 위치로 설정
                    map.setCenter(latlng); // 지도 중심을 클릭한 위치로 설정
                
                  try {
                  // Dart로 좌표 정보 전달
                  var message = JSON.stringify({lat: latlng.getLat(), lng: latlng.getLng()});
                  console.log(message); // message 로그 출력
                  window.flutter_inappwebview.callHandler('mapClickHandler', message)
                      .then(function(result) {
                          console.log("Dart로 메시지 전달 성공:", result);
                      })
                      .catch(function(error) {
                          console.error("Dart로 메시지 전달 중 오류 발생:", error);
                      });
                } catch (error) {
                    console.error("예상치 못한 오류 발생:", error);
                }
                });
            </script>
        </body>
        </html>
        ''';

      _controller?.loadUrl(Uri.dataFromString(html,
              mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
          .toString()); // 웹뷰에 HTML 콘텐츠 로드
      print("************not null************");
      print(kakaoJsApiKey);
      print(_currentPosition!.latitude);
      print(_currentPosition!.longitude);
    } else {
      print("************null************");
    }
  }

  @override
  Widget build(BuildContext context) {
    Place place = Provider.of<Place>(context);

    return Stack(
      children: [
        Container(
          height: 400,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              WebView(
                initialUrl: '',
                onWebViewCreated: (controller) {
                  _controller = controller;
                  _loadHtmlFromAssets();
                },
                javascriptMode: JavascriptMode.unrestricted, // 자바스크립트 허용
                javascriptChannels: <JavascriptChannel>{
                  JavascriptChannel(
                    name: 'mapClickHandler',
                    onMessageReceived: (JavascriptMessage message) {
                      var data = jsonDecode(message.message);
                      double latitude = data['lat'];
                      double longitude = data['lng'];

                      // Place 모델에 저장
                      place.setLatitude(latitude);
                      place.setLongitude(longitude);
                    },
                  ),
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
