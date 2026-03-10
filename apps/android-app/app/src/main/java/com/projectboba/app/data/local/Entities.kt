package com.projectboba.app.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "tasks")
data class TaskEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val title: String,
    val notes: String = "",
    val pointValue: Int,
    val tags: List<String>,
    val isStarter: Boolean,
    val isArchived: Boolean = false,
)

@Entity(tableName = "task_completions")
data class TaskCompletionEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val taskId: Long,
    val completedAt: Long,
    val pointsAwarded: Int,
    val tags: List<String>,
)

@Entity(tableName = "shop_items")
data class ShopItemEntity(
    @PrimaryKey val id: String,
    val title: String,
    val description: String,
    val cost: Int,
    val type: String,
    val target: String,
    val requiredTag: String,
    val contentValue: String,
    val isStarterUnlocked: Boolean = false,
)

@Entity(tableName = "owned_items")
data class OwnedItemEntity(
    @PrimaryKey val itemId: String,
    val ownedAt: Long,
)

@Entity(tableName = "progress")
data class ProgressEntity(
    @PrimaryKey val id: Int = 1,
    val pointsBalance: Int,
    val lifetimePoints: Int,
    val streakCount: Int,
    val lastQualifiedDate: String?,
)

@Entity(tableName = "phrases")
data class PhraseEntity(
    @PrimaryKey val id: String,
    val text: String,
    val pack: String,
    val requiredItemId: String? = null,
)
