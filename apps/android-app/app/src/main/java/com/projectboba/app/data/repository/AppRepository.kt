package com.projectboba.app.data.repository

import com.projectboba.app.data.local.CompletionDao
import com.projectboba.app.data.local.OwnedItemDao
import com.projectboba.app.data.local.OwnedItemEntity
import com.projectboba.app.data.local.PhraseDao
import com.projectboba.app.data.local.ProgressDao
import com.projectboba.app.data.local.ProgressEntity
import com.projectboba.app.data.local.ShopDao
import com.projectboba.app.data.local.ShopItemEntity
import com.projectboba.app.data.local.TaskCompletionEntity
import com.projectboba.app.data.local.TaskDao
import com.projectboba.app.data.local.TaskEntity
import com.projectboba.app.data.local.UserPreferences
import com.projectboba.app.data.local.UserPreferencesRepository
import com.projectboba.app.domain.Progress
import com.projectboba.app.domain.ShopItem
import com.projectboba.app.domain.Task
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

class AppRepository(
    private val taskDao: TaskDao,
    private val completionDao: CompletionDao,
    private val shopDao: ShopDao,
    private val ownedItemDao: OwnedItemDao,
    private val progressDao: ProgressDao,
    private val phraseDao: PhraseDao,
    private val preferencesRepository: UserPreferencesRepository,
) {
    val tasks: Flow<List<Task>> = taskDao.observeTasks().map { tasks ->
        tasks.map { it.toDomain() }
    }

    val progress: Flow<Progress> = progressDao.observeProgress().map {
        it?.toDomain() ?: Progress(0, 0, 0, null)
    }

    val preferences: Flow<UserPreferences> = preferencesRepository.preferences

    val todayCompletionCount: Flow<Int> = completionDao.observeCompletions().map { completions ->
        val today = LocalDate.now()
        completions.count { completion ->
            Instant.ofEpochMilli(completion.completedAt).atZone(ZoneId.systemDefault()).toLocalDate() == today
        }
    }

    val shopItems: Flow<List<ShopItem>> =
        combine(shopDao.observeItems(), ownedItemDao.observeOwned(), preferences) { items, owned, prefs ->
            val ownedIds = owned.map { it.itemId }.toSet()
            items.map { item ->
                item.toDomain(
                    owned = item.isStarterUnlocked || ownedIds.contains(item.id),
                    equipped = when (item.target) {
                        "hat" -> prefs.equippedHatId == item.id
                        "scarf" -> prefs.equippedScarfId == item.id
                        "eyewear" -> prefs.equippedEyewearId == item.id
                        "gloves" -> prefs.equippedGlovesId == item.id
                        "accessory" -> prefs.equippedAccessoryId == item.id
                        "background" -> prefs.backgroundId == item.contentValue
                        else -> false
                    },
                )
            }
        }

    val phrases = combine(phraseDao.observePhrases(), ownedItemDao.observeOwned()) { phrases, owned ->
        val ownedIds = owned.map { it.itemId }.toSet()
        phrases.filter { it.requiredItemId == null || ownedIds.contains(it.requiredItemId) }
    }

    suspend fun seedIfNeeded() {
        if (taskDao.count() == 0) {
            taskDao.insertAll(SeedData.starterTasks)
        }
        if (shopDao.count() == 0) {
            shopDao.insertAll(SeedData.shopItems)
        }
        if (phraseDao.count() == 0) {
            phraseDao.insertAll(SeedData.phrases)
        }
        progressDao.upsert(progressDao.observeProgress().first() ?: ProgressEntity(1, 40, 40, 0, null))
    }

    suspend fun addTask(title: String, notes: String, points: Int, tags: List<String>) {
        taskDao.insert(TaskEntity(title = title, notes = notes, pointValue = points, tags = tags, isStarter = false))
    }

    suspend fun completeTask(task: Task, nowMillis: Long = System.currentTimeMillis()): Int {
        completionDao.insert(
            TaskCompletionEntity(
                taskId = task.id,
                completedAt = nowMillis,
                pointsAwarded = task.pointValue,
                tags = task.tags,
            ),
        )
        val progress = progress.first()
        val today = Instant.ofEpochMilli(nowMillis).atZone(ZoneId.systemDefault()).toLocalDate()
        val todayCount = completionDao.countBetween(today.startMillis(), today.endMillis())
        val lastQualified = progress.lastQualifiedDate?.let(LocalDate::parse)
        val streak = when {
            todayCount < 3 -> progress.streakCount
            lastQualified == today -> progress.streakCount
            lastQualified == today.minusDays(1) -> progress.streakCount + 1
            else -> 1
        }
        progressDao.upsert(
            ProgressEntity(
                id = 1,
                pointsBalance = progress.pointsBalance + task.pointValue,
                lifetimePoints = progress.lifetimePoints + task.pointValue,
                streakCount = streak,
                lastQualifiedDate = if (todayCount >= 3) today.toString() else progress.lastQualifiedDate,
            ),
        )
        return task.pointValue
    }

    suspend fun purchase(item: ShopItem): Boolean {
        if (item.owned) return true
        val progress = progress.first()
        if (progress.pointsBalance < item.cost) return false
        ownedItemDao.insert(OwnedItemEntity(item.id, System.currentTimeMillis()))
        progressDao.upsert(
            ProgressEntity(
                id = 1,
                pointsBalance = progress.pointsBalance - item.cost,
                lifetimePoints = progress.lifetimePoints,
                streakCount = progress.streakCount,
                lastQualifiedDate = progress.lastQualifiedDate,
            ),
        )
        if (item.type == "background") {
            equipItem(item)
        }
        return true
    }

    suspend fun equipItem(item: ShopItem) {
        preferencesRepository.update { prefs ->
            when (item.target) {
                "hat" -> prefs.copy(equippedHatId = item.id)
                "scarf" -> prefs.copy(equippedScarfId = item.id)
                "eyewear" -> prefs.copy(equippedEyewearId = item.id)
                "gloves" -> prefs.copy(equippedGlovesId = item.id)
                "accessory" -> prefs.copy(equippedAccessoryId = item.id)
                "background" -> prefs.copy(backgroundId = item.contentValue)
                else -> prefs
            }
        }
    }

    suspend fun updateAvatar(avatarId: String? = null, avatarName: String? = null) {
        preferencesRepository.update { prefs ->
            prefs.copy(
                avatarId = avatarId ?: prefs.avatarId,
                avatarName = avatarName ?: prefs.avatarName,
            )
        }
    }

    suspend fun toggleSound() {
        preferencesRepository.update { prefs -> prefs.copy(soundEnabled = !prefs.soundEnabled) }
    }

    suspend fun markPhraseShown(at: Long) {
        preferencesRepository.update { prefs -> prefs.copy(lastPhraseAt = at) }
    }

    private fun TaskEntity.toDomain() = Task(id, title, notes, pointValue, tags, isStarter)

    private fun ProgressEntity.toDomain() = Progress(pointsBalance, lifetimePoints, streakCount, lastQualifiedDate)

    private fun ShopItemEntity.toDomain(owned: Boolean, equipped: Boolean) = ShopItem(
        id = id,
        title = title,
        description = description,
        cost = cost,
        type = type,
        target = target,
        requiredTag = requiredTag,
        contentValue = contentValue,
        owned = owned,
        equipped = equipped,
        isStarterUnlocked = isStarterUnlocked,
    )
}

private fun LocalDate.startMillis(): Long =
    atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()

private fun LocalDate.endMillis(): Long =
    plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli() - 1
