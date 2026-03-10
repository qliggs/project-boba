package com.projectboba.app.core

import android.content.Context
import com.projectboba.app.data.local.AppDatabase
import com.projectboba.app.data.local.UserPreferencesRepository
import com.projectboba.app.data.repository.AppRepository

class AppContainer(context: Context) {
    private val database = AppDatabase.build(context)
    private val preferencesRepository = UserPreferencesRepository(context)

    val repository = AppRepository(
        taskDao = database.taskDao(),
        completionDao = database.completionDao(),
        shopDao = database.shopDao(),
        ownedItemDao = database.ownedItemDao(),
        progressDao = database.progressDao(),
        phraseDao = database.phraseDao(),
        preferencesRepository = preferencesRepository,
    )
}
