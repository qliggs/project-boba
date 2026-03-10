package com.projectboba.app.data.local

import androidx.room.TypeConverter

class Converters {
    @TypeConverter
    fun fromList(value: List<String>): String = value.joinToString("|")

    @TypeConverter
    fun toList(value: String): List<String> = value.split("|").filter { it.isNotBlank() }
}
