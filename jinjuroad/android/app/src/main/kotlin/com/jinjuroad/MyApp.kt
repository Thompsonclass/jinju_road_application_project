// kotlin
package com.jinjuroad

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.jinjuroad.BuildConfig // <- BuildConfig 임포트 추가

class MyApp : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 예: BuildConfig로 주입한 Kakao 키 사용
        val kakaoKey = BuildConfig.KAKAO_MAP_KEY
        // kakaoKey를 네이티브 초기화 등에 사용
    }
}
