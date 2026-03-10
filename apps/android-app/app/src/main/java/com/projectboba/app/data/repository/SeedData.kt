package com.projectboba.app.data.repository

import com.projectboba.app.data.local.PhraseEntity
import com.projectboba.app.data.local.ShopItemEntity
import com.projectboba.app.data.local.TaskEntity

object SeedData {
    val starterTasks = listOf(
        TaskEntity(title = "Brush teeth", pointValue = 5, tags = listOf("Hygiene"), isStarter = true),
        TaskEntity(title = "Drink water", pointValue = 5, tags = listOf("Health", "Self-care"), isStarter = true),
        TaskEntity(title = "Make bed", pointValue = 10, tags = listOf("Chores"), isStarter = true),
        TaskEntity(title = "Shower", pointValue = 10, tags = listOf("Hygiene", "Self-care"), isStarter = true),
        TaskEntity(title = "Take meds", pointValue = 10, tags = listOf("Health"), isStarter = true),
        TaskEntity(title = "Vacuum", pointValue = 20, tags = listOf("Chores"), isStarter = true),
        TaskEntity(title = "Dishes", pointValue = 10, tags = listOf("Chores"), isStarter = true),
        TaskEntity(title = "Laundry", pointValue = 20, tags = listOf("Chores"), isStarter = true),
        TaskEntity(title = "Journal", pointValue = 20, tags = listOf("Mental health", "Creative"), isStarter = true),
        TaskEntity(title = "Stretch", pointValue = 10, tags = listOf("Health", "Self-care"), isStarter = true),
        TaskEntity(title = "Walk", pointValue = 20, tags = listOf("Health"), isStarter = true),
    )

    val shopItems = listOf(
        ShopItemEntity("hat_beanie", "Cocoa Beanie", "A soft knit hat for chilly mornings.", 60, "cosmetic", "hat", "Hygiene", "beanie"),
        ShopItemEntity("scarf_plaid", "Plaid Scarf", "A cozy scarf with cabin energy.", 75, "cosmetic", "scarf", "Chores", "plaid"),
        ShopItemEntity("eyewear_round", "Round Glasses", "Warm bookshop glasses.", 80, "cosmetic", "eyewear", "Work", "round"),
        ShopItemEntity("gloves_mittens", "Cloud Mittens", "Little puffy mittens.", 70, "cosmetic", "gloves", "Health", "mittens"),
        ShopItemEntity("accessory_star", "Star Pin", "A tiny sparkle pin for proud days.", 50, "cosmetic", "accessory", "Creative", "star"),
        ShopItemEntity("bg_twilight", "Twilight Window", "A dusky room with snowy panes.", 120, "background", "background", "Mental health", "twilight_window"),
        ShopItemEntity("bg_market", "Winter Market", "Lanterns and warm stalls.", 140, "background", "background", "Social", "winter_market"),
        ShopItemEntity("fx_hearts", "Heart Burst", "Swap sparkles for tiny hearts.", 90, "effect", "completion_effect", "Self-care", "hearts"),
        ShopItemEntity("phrases_supportive", "Supportive Phrases", "Extra kind words for tap moments.", 65, "phrase_pack", "phrases", "Self-care", "supportive_pack"),
        ShopItemEntity("phrases_whimsy", "Whimsy Pack", "Sillier cozy one-liners.", 65, "phrase_pack", "phrases", "Creative", "whimsy_pack"),
    )

    val phrases = listOf(
        PhraseEntity("base_1", "You did a little good thing. That counts.", "base"),
        PhraseEntity("base_2", "Tiny steps still make a path.", "base"),
        PhraseEntity("base_3", "I am legally required to cheer for you now.", "base"),
        PhraseEntity("base_4", "Warm tea energy only.", "base"),
        PhraseEntity("base_5", "You are doing enough for this moment.", "base"),
        PhraseEntity("base_6", "%s, I am very impressed with your cozy momentum.", "base"),
        PhraseEntity("support_1", "%s, you are allowed to be proud of small wins.", "supportive_pack", "phrases_supportive"),
        PhraseEntity("support_2", "Gentle progress is still progress.", "supportive_pack", "phrases_supportive"),
        PhraseEntity("whimsy_1", "Emergency glitter report: vibes are excellent.", "whimsy_pack", "phrases_whimsy"),
        PhraseEntity("whimsy_2", "I would do a cartwheel, but I am very round.", "whimsy_pack", "phrases_whimsy"),
    )

    val tagOptions = listOf(
        "Hygiene",
        "Chores",
        "Work",
        "Self-care",
        "Mental health",
        "Social",
        "Health",
        "Creative",
    )

    val backgrounds = mapOf(
        "snowy_nook" to "Snowy Nook",
        "twilight_window" to "Twilight Window",
        "winter_market" to "Winter Market",
    )
}
