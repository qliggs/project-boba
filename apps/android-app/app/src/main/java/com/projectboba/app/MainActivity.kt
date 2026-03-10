package com.projectboba.app

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.projectboba.app.core.MainViewModel
import com.projectboba.app.core.MainViewModelFactory
import com.projectboba.app.ui.BobaApp
import com.projectboba.app.ui.theme.ProjectBobaTheme

class MainActivity : ComponentActivity() {
    private val viewModel: MainViewModel by viewModels {
        MainViewModelFactory((application as ProjectBobaApplication).container.repository)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val state = viewModel.uiState.collectAsStateWithLifecycle()
            val haptics = LocalHapticFeedback.current

            LaunchedEffect(Unit) {
                viewModel.completionEvents.collect {
                    haptics.performHapticFeedback(HapticFeedbackType.LongPress)
                    if (state.value.home.soundEnabled) {
                        ToneGenerator(AudioManager.STREAM_NOTIFICATION, 80).startTone(
                            ToneGenerator.TONE_PROP_BEEP2,
                            120,
                        )
                    }
                }
            }

            ProjectBobaTheme {
                BobaApp(viewModel = viewModel, state = state.value)
            }
        }
    }
}
