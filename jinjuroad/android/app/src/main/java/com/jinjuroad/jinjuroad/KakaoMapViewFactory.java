package com.jinjuroad.jinjuroad;

import android.content.Context;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class KakaoMapViewFactory extends PlatformViewFactory {
    public KakaoMapViewFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        return new KakaoMapView(context, viewId, args);
    }
}
