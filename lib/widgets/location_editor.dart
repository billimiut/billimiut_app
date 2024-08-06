import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/providers/place.dart';

class LocationEditor extends StatefulWidget {
  final String docId; // 클릭한 리스트 아이템의 document id
  const LocationEditor({super.key, required this.docId});

  @override
  State<LocationEditor> createState() => _LocationEditorState();
}

class _LocationEditorState extends State<LocationEditor> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  void _loadHtmlFromAssets(double latitude, double longitude) {
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
                  center: new kakao.maps.LatLng(${latitude}, ${longitude}),
                  level: 2
              };
              var map = new kakao.maps.Map(container, options);

              var marker = new kakao.maps.Marker({
                  position: new kakao.maps.LatLng(${latitude}, ${longitude}),
                  draggable: true
              });
              marker.setMap(map);

              // 지도 클릭 이벤트를 추가하여 마커를 클릭한 위치로 이동시키기
              kakao.maps.event.addListener(map, 'click', function(mouseEvent) {
                  var latlng = mouseEvent.latLng; // 클릭한 위치의 좌표
                  marker.setPosition(latlng); // 마커의 위치를 클릭한 위치로 설정
                  map.setCenter(latlng); // 지도 중심을 클릭한 위치로 설정
                  console.log(latlng.getLat(), latlng.getLng());
              
                
                // Dart로 좌표 정보 전달
                var message = JSON.stringify({lat: latlng.getLat(), lng: latlng.getLng()});
                console.log(message); // message 로그 출력
                window.postMessage(message, '*');
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
    print(latitude);
    print(longitude);
  }

  @override
  Widget build(BuildContext context) {
    Posts postsProvider = Provider.of<Posts>(context);
    Place place = Provider.of<Place>(context);

    Map<String, dynamic>? data = postsProvider.allPosts
        .firstWhere((post) => post['post_id'] == widget.docId, orElse: () => null);
    
    if (data == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text("해당 게시물이 존재하지 않습니다."),
        ),
      );
    }

    double latitude = 0.0, longitude = 0.0;
    if (data['map_coordinate'] != null && data['map_coordinate'] != null) {
      latitude = data['map_coordinate']['latitude'];
      longitude = data['map_coordinate']['longitude'];
    }

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
                  _loadHtmlFromAssets(latitude, longitude);
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
                      print('New coordinates: $latitude, $longitude'); // 추가된 디버그 출력
                    },
                  ),
                },
                onPageFinished: (String url) {
                  _controller?.runJavascript('''
                    window.addEventListener('message', (event) => {
                      if (event.origin !== window.location.origin) return;
                      mapClickHandler.postMessage(event.data);
                    });
                  ''');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}