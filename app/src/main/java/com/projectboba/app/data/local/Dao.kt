package com.projectboba.app.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface TaskDao {
    @Query("SELECT * FROM tasks WHERE isArchived = 0 ORDER BY title ASC")
    fun observeTasks(): Flow<List<TaskEntity>>

    @Insert
    suspend fun insert(task: TaskEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(tasks: List<TaskEntity>)

    @Update
    suspend fun update(task: TaskEntity)

    @Query("SELECT COUNT(*) FROM tasks")
    suspend fun count(): Int
}

@Dao
interface CompletionDao {
    @Query("SELECT * FROM task_completions ORDER BY completedAt DESC")
    fun observeCompletions(): Flow<List<TaskCompletionEntity>>

    @Insert
    suspend fun insert(completion: TaskCompletionEntity)

    @Query("SELECT COUNT(*) FROM task_completions WHERE completedAt BETWEEN :start AND :end")
    suspend fun countBetween(start: Long, end: Long): Int
}

@Dao
interface ShopDao {
    @Query("SELECT * FROM shop_items ORDER BY cost ASC")
    fun observeItems(): Flow<List<ShopItemEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(items: List<ShopItemEntity>)

    @Query("SELECT COUNT(*) FROM shop_items")
    suspend fun count(): Int
}

@Dao
interface OwnedItemDao {
    @Query("SELECT * FROM owned_items")
    fun observeOwned(): Flow<List<OwnedItemEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(item: OwnedItemEntity)
}

@Dao
interface ProgressDao {
    @Query("SELECT * FROM progress WHERE id = 1")
    fun observeProgress(): Flow<ProgressEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(progress: ProgressEntity)
}

@Dao
interface PhraseDao {
    @Query("SELECT * FROM phrases")
    fun observePhrases(): Flow<List<PhraseEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(phrases: List<PhraseEntity>)

    @Query("SELECT COUNT(*) FROM phrases")
    suspend fun count(): Int
}
