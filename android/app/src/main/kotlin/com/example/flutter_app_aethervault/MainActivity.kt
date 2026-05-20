package com.example.flutter_app_aethervault

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		// Keep screen on while app is running
		window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
	}
}
