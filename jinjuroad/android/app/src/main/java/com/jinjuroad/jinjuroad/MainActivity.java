package com.jinjuroad.jinjuroad;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        // kakao_map_view 라는 viewType으로 Flutter에서 사용
        flutterEngine.getPlatformViewsController()
                .getRegistry()
                .registerViewFactory("kakao_map_view", new KakaoMapViewFactory());
    }
}
