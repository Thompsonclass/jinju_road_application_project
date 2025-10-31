package com.jinjuroad.jinjuroad;

import android.content.Context;
import android.view.View;
import android.widget.FrameLayout;
import android.util.Log;
import io.flutter.plugin.platform.PlatformView;

public class KakaoMapView implements PlatformView {
    private final FrameLayout container;
    private final View mapView;

    public KakaoMapView(Context context, int id, Object args) {
        container = new FrameLayout(context);
        View created = null;
        try {
            // 가능한 SDK 클래스명들 시도 (프로젝트 사용 SDK에 맞게 조정 가능)
            String[] candidates = new String[] {
                    "com.kakao.maps.MapView",
                    "net.daum.mf.map.api.MapView",
                    "com.kakao.map.sdk.MapView" // 예비
            };
            for (String cls : candidates) {
                try {
                    Class<?> mapClazz = Class.forName(cls);
                    // MapView 생성자에 Context만 받는 경우를 먼저 시도
                    try {
                        created = (View) mapClazz.getConstructor(Context.class).newInstance(context);
                        break;
                    } catch (NoSuchMethodException e) {
                        // 다른 생성자 시도 필요하면 확장
                    }
                } catch (ClassNotFoundException ignored) {
                }
            }
        } catch (Exception e) {
            Log.e("KakaoMapView", "MapView create failed", e);
        }

        if (created == null) {
            // SDK 없거나 생성 실패 시 빈 뷰(앱 크래시 방지). 개발 중에는 로그 또는 배경색으로 알림.
            FrameLayout fallback = new FrameLayout(context);
            fallback.setBackgroundColor(0xFFEFEFEF); // 밝은 회색
            created = fallback;
        }

        mapView = created;
        container.addView(mapView);
    }

    @Override
    public View getView() {
        return container;
    }

    @Override
    public void dispose() {
        // 필요 시 MapView 자원 정리
    }
}
