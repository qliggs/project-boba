package com.projectboba.app.data.local

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.MutablePreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore(name = "project_boba_prefs")

data class UserPreferences(
    val avatarId: String = "penguin",
    val avatarName: String = "Boba",
    val backgroundId: String = "snowy_nook",
    val equippedHatId: String? = null,
    val equippedScarfId: String? = null,
    val equippedEyewearId: String? = null,
    val equippedGlovesId: String? = null,
    val equippedAccessoryId: String? = null,
    val soundEnabled: Boolean = true,
    val lastPhraseAt: Long = 0L,
)

class UserPreferencesRepository(private val context: Context) {
    private object Keys {
        val avatarId = stringPreferencesKey("avatar_id")
        val avatarName = stringPreferencesKey("avatar_name")
        val backgroundId = stringPreferencesKey("background_id")
        val equippedHatId = stringPreferencesKey("equipped_hat_id")
        val equippedScarfId = stringPreferencesKey("equipped_scarf_id")
        val equippedEyewearId = stringPreferencesKey("equipped_eyewear_id")
        val equippedGlovesId = stringPreferencesKey("equipped_gloves_id")
        val equippedAccessoryId = stringPreferencesKey("equipped_accessory_id")
        val soundEnabled = booleanPreferencesKey("sound_enabled")
        val lastPhraseAt = longPreferencesKey("last_phrase_at")
    }

    val preferences: Flow<UserPreferences> = context.dataStore.data.map { prefs ->
        UserPreferences(
            avatarId = prefs[Keys.avatarId] ?: "penguin",
            avatarName = prefs[Keys.avatarName] ?: "Boba",
            backgroundId = prefs[Keys.backgroundId] ?: "snowy_nook",
            equippedHatId = prefs[Keys.equippedHatId],
            equippedScarfId = prefs[Keys.equippedScarfId],
            equippedEyewearId = prefs[Keys.equippedEyewearId],
            equippedGlovesId = prefs[Keys.equippedGlovesId],
            equippedAccessoryId = prefs[Keys.equippedAccessoryId],
            soundEnabled = prefs[Keys.soundEnabled] ?: true,
            lastPhraseAt = prefs[Keys.lastPhraseAt] ?: 0L,
        )
    }

    suspend fun update(block: suspend (UserPreferences) -> UserPreferences) {
        context.dataStore.edit { prefs ->
            val current = prefs.toUserPreferences()
            val next = block(current)
            prefs[Keys.avatarId] = next.avatarId
            prefs[Keys.avatarName] = next.avatarName
            prefs[Keys.backgroundId] = next.backgroundId
            writeNullable(prefs, Keys.equippedHatId, next.equippedHatId)
            writeNullable(prefs, Keys.equippedScarfId, next.equippedScarfId)
            writeNullable(prefs, Keys.equippedEyewearId, next.equippedEyewearId)
            writeNullable(prefs, Keys.equippedGlovesId, next.equippedGlovesId)
            writeNullable(prefs, Keys.equippedAccessoryId, next.equippedAccessoryId)
            prefs[Keys.soundEnabled] = next.soundEnabled
            prefs[Keys.lastPhraseAt] = next.lastPhraseAt
        }
    }

    private fun Preferences.toUserPreferences(): UserPreferences =
        UserPreferences(
            avatarId = this[Keys.avatarId] ?: "penguin",
            avatarName = this[Keys.avatarName] ?: "Boba",
            backgroundId = this[Keys.backgroundId] ?: "snowy_nook",
            equippedHatId = this[Keys.equippedHatId],
            equippedScarfId = this[Keys.equippedScarfId],
            equippedEyewearId = this[Keys.equippedEyewearId],
            equippedGlovesId = this[Keys.equippedGlovesId],
            equippedAccessoryId = this[Keys.equippedAccessoryId],
            soundEnabled = this[Keys.soundEnabled] ?: true,
            lastPhraseAt = this[Keys.lastPhraseAt] ?: 0L,
        )

    private fun writeNullable(
        prefs: MutablePreferences,
        key: Preferences.Key<String>,
        value: String?,
    ) {
        if (value == null) {
            prefs.remove(key)
        } else {
            prefs[key] = value
        }
    }
}
