package com.projectboba.app.domain

data class Task(
    val id: Long,
    val title: String,
    val notes: String,
    val pointValue: Int,
    val tags: List<String>,
    val isStarter: Boolean,
)

data class ShopItem(
    val id: String,
    val title: String,
    val description: String,
    val cost: Int,
    val type: String,
    val target: String,
    val requiredTag: String,
    val contentValue: String,
    val owned: Boolean,
    val equipped: Boolean,
    val isStarterUnlocked: Boolean,
)

data class Progress(
    val pointsBalance: Int,
    val lifetimePoints: Int,
    val streakCount: Int,
    val lastQualifiedDate: String?,
)

data class AvatarChoice(
    val id: String,
    val title: String,
    val accent: Long,
)

data class HomeUiState(
    val avatarName: String = "Boba",
    val avatarId: String = "penguin",
    val backgroundId: String = "snowy_nook",
    val pointsBalance: Int = 0,
    val streakCount: Int = 0,
    val todayCompletedCount: Int = 0,
    val tasks: List<Task> = emptyList(),
    val equippedHatId: String? = null,
    val equippedScarfId: String? = null,
    val equippedEyewearId: String? = null,
    val equippedGlovesId: String? = null,
    val equippedAccessoryId: String? = null,
    val soundEnabled: Boolean = true,
)
