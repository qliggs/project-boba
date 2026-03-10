package com.projectboba.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val CozyLight = lightColorScheme(
    primary = Color(0xFF82543A),
    onPrimary = Color(0xFFFFF8F2),
    secondary = Color(0xFF6C7B6B),
    onSecondary = Color.White,
    tertiary = Color(0xFF5F7391),
    background = Color(0xFFF6EFE8),
    surface = Color(0xFFFFFBF7),
    onSurface = Color(0xFF2E2A27),
)

private val CozyDark = darkColorScheme(
    primary = Color(0xFFE6B48F),
    secondary = Color(0xFFB7C7B4),
    tertiary = Color(0xFFB7C6E0),
    background = Color(0xFF1E2329),
    surface = Color(0xFF252C33),
    onSurface = Color(0xFFF8F1EA),
)

@Composable
fun ProjectBobaTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = if (isSystemInDarkTheme()) CozyDark else CozyLight,
        typography = BobaTypography,
        content = content,
    )
}
