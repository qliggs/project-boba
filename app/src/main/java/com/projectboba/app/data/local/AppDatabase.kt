package com.projectboba.app.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

@Database(
    entities = [
        TaskEntity::class,
        TaskCompletionEntity::class,
        ShopItemEntity::class,
        OwnedItemEntity::class,
        ProgressEntity::class,
        PhraseEntity::class,
    ],
    version = 1,
    exportSchema = false,
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun taskDao(): TaskDao
    abstract fun completionDao(): CompletionDao
    abstract fun shopDao(): ShopDao
    abstract fun ownedItemDao(): OwnedItemDao
    abstract fun progressDao(): ProgressDao
    abstract fun phraseDao(): PhraseDao

    companion object {
        fun build(context: Context): AppDatabase =
            Room.databaseBuilder(context, AppDatabase::class.java, "project-boba.db").build()
    }
}
