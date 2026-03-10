package com.projectboba.app.core

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.projectboba.app.data.repository.AppRepository
import com.projectboba.app.data.repository.SeedData
import com.projectboba.app.domain.AvatarChoice
import com.projectboba.app.domain.HomeUiState
import com.projectboba.app.domain.ShopItem
import com.projectboba.app.domain.Task
import kotlin.random.Random
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class AppUiState(
    val home: HomeUiState = HomeUiState(),
    val shopItems: List<ShopItem> = emptyList(),
    val tagOptions: List<String> = SeedData.tagOptions,
    val backgrounds: Map<String, String> = SeedData.backgrounds,
    val avatars: List<AvatarChoice> = listOf(
        AvatarChoice("penguin", "Penguin", 0xFF4F6D7AL),
        AvatarChoice("bear", "Bear", 0xFF8D6E63L),
        AvatarChoice("bunny", "Bunny", 0xFFE8B5C6L),
    ),
)

data class TaskDraft(
    val title: String = "",
    val notes: String = "",
    val points: Int = 10,
    val tags: Set<String> = emptySet(),
)

class MainViewModel(private val repository: AppRepository) : ViewModel() {
    val uiState: StateFlow<AppUiState> =
        combine(
            repository.tasks,
            repository.progress,
            repository.preferences,
            repository.shopItems,
            repository.todayCompletionCount,
        ) { tasks, progress, prefs, items, todayCompletionCount ->
            AppUiState(
                home = HomeUiState(
                    avatarName = prefs.avatarName,
                    avatarId = prefs.avatarId,
                    backgroundId = prefs.backgroundId,
                    pointsBalance = progress.pointsBalance,
                    streakCount = progress.streakCount,
                    todayCompletedCount = todayCompletionCount,
                    tasks = tasks,
                    equippedHatId = prefs.equippedHatId,
                    equippedScarfId = prefs.equippedScarfId,
                    equippedEyewearId = prefs.equippedEyewearId,
                    equippedGlovesId = prefs.equippedGlovesId,
                    equippedAccessoryId = prefs.equippedAccessoryId,
                    soundEnabled = prefs.soundEnabled,
                ),
                shopItems = items,
            )
        }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), AppUiState())

    val completionEvents = MutableSharedFlow<Int>()
    val phraseEvents = MutableSharedFlow<String>()

    init {
        viewModelScope.launch {
            repository.seedIfNeeded()
        }
    }

    fun completeTask(task: Task) {
        viewModelScope.launch {
            val awarded = repository.completeTask(task)
            completionEvents.emit(awarded)
        }
    }

    fun addTask(draft: TaskDraft) {
        if (draft.title.isBlank() || draft.tags.isEmpty()) return
        viewModelScope.launch {
            repository.addTask(
                title = draft.title.trim(),
                notes = draft.notes.trim(),
                points = draft.points,
                tags = draft.tags.toList(),
            )
        }
    }

    fun purchase(item: ShopItem) {
        viewModelScope.launch {
            repository.purchase(item)
        }
    }

    fun equip(item: ShopItem) {
        viewModelScope.launch {
            repository.equipItem(item)
        }
    }

    fun chooseAvatar(avatarId: String) {
        viewModelScope.launch {
            repository.updateAvatar(avatarId = avatarId)
        }
    }

    fun updateAvatarName(name: String) {
        viewModelScope.launch {
            repository.updateAvatar(avatarName = name.ifBlank { "Boba" })
        }
    }

    fun toggleSound() {
        viewModelScope.launch {
            repository.toggleSound()
        }
    }

    fun requestPhrase() {
        viewModelScope.launch {
            val prefs = repository.preferences.first()
            val now = System.currentTimeMillis()
            if (now - prefs.lastPhraseAt < 4_000) return@launch
            val phrases = repository.phrases.first()
            if (phrases.isEmpty()) return@launch
            val selected = phrases[Random.nextInt(phrases.size)].text.format(prefs.avatarName)
            repository.markPhraseShown(now)
            phraseEvents.emit(selected)
        }
    }
}

class MainViewModelFactory(private val repository: AppRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MainViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return MainViewModel(repository) as T
        }
        error("Unknown ViewModel class: ${modelClass.name}")
    }
}
