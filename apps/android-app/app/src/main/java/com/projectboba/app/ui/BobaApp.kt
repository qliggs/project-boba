package com.projectboba.app.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material.icons.rounded.Face
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material.icons.rounded.ShoppingBag
import androidx.compose.material.icons.rounded.Star
import androidx.compose.material.icons.rounded.TaskAlt
import androidx.compose.material3.AssistChip
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.projectboba.app.core.AppUiState
import com.projectboba.app.core.MainViewModel
import com.projectboba.app.core.TaskDraft
import com.projectboba.app.domain.ShopItem
import com.projectboba.app.domain.Task
import kotlinx.coroutines.launch

private enum class Destination(val route: String, val label: String) {
    Home("home", "Home"),
    Tasks("tasks", "Tasks"),
    Shop("shop", "Shop"),
    Avatar("avatar", "Avatar"),
    Settings("settings", "Settings"),
}

@Composable
fun BobaApp(viewModel: MainViewModel, state: AppUiState) {
    val navController = rememberNavController()

    Scaffold(
        bottomBar = {
            val backStack by navController.currentBackStackEntryAsState()
            val currentRoute = backStack?.destination?.route
            NavigationBar {
                listOf(
                    Destination.Home to Icons.Rounded.Star,
                    Destination.Tasks to Icons.Rounded.TaskAlt,
                    Destination.Shop to Icons.Rounded.ShoppingBag,
                    Destination.Avatar to Icons.Rounded.Face,
                    Destination.Settings to Icons.Rounded.Settings,
                ).forEach { (destination, icon) ->
                    NavigationBarItem(
                        selected = currentRoute == destination.route,
                        onClick = {
                            navController.navigate(destination.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = { Icon(icon, contentDescription = destination.label) },
                        label = { Text(destination.label) },
                    )
                }
            }
        },
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = Destination.Home.route,
            modifier = Modifier.padding(padding),
        ) {
            composable(Destination.Home.route) {
                HomeScreen(state = state, viewModel = viewModel)
            }
            composable(Destination.Tasks.route) {
                TasksScreen(state = state, viewModel = viewModel)
            }
            composable(Destination.Shop.route) {
                ShopScreen(state = state, viewModel = viewModel)
            }
            composable(Destination.Avatar.route) {
                AvatarScreen(state = state, viewModel = viewModel)
            }
            composable(Destination.Settings.route) {
                SettingsScreen(state = state, viewModel = viewModel)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun HomeScreen(state: AppUiState, viewModel: MainViewModel) {
    var panelOpen by remember { mutableStateOf(false) }
    var phrase by remember { mutableStateOf<String?>(null) }
    val hopOffset = remember { Animatable(0f) }
    val sparkleAlpha = remember { Animatable(0f) }
    var pointsBurst by remember { mutableIntStateOf(0) }
    val scope = rememberCoroutineScope()

    LaunchedEffect(Unit) {
        viewModel.completionEvents.collect { points ->
            pointsBurst = points
            scope.launch {
                hopOffset.snapTo(0f)
                hopOffset.animateTo(-26f, tween(130, easing = FastOutSlowInEasing))
                hopOffset.animateTo(0f, tween(210, easing = FastOutSlowInEasing))
            }
            scope.launch {
                sparkleAlpha.snapTo(1f)
                sparkleAlpha.animateTo(0f, tween(650))
            }
        }
    }
    LaunchedEffect(Unit) {
        viewModel.phraseEvents.collect { phrase = it }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(backgroundBrush(state.home.backgroundId)),
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            CenterAlignedTopAppBar(
                title = { Text("Project Boba") },
                actions = {
                    IconButton(onClick = { panelOpen = !panelOpen }) {
                        Icon(Icons.Rounded.TaskAlt, contentDescription = "Quick tasks")
                    }
                },
            )
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 20.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Spacer(Modifier.height(18.dp))
                Surface(
                    shape = RoundedCornerShape(24.dp),
                    color = MaterialTheme.colorScheme.surface.copy(alpha = 0.85f),
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp),
                        horizontalArrangement = Arrangement.spacedBy(16.dp),
                    ) {
                        CozyStat("Points", state.home.pointsBalance.toString())
                        CozyStat("Streak", "${state.home.streakCount} days")
                        CozyStat("Today", "${state.home.todayCompletedCount}/3")
                    }
                }
                Spacer(Modifier.height(24.dp))
                AnimatedVisibility(visible = phrase != null) {
                    Card(
                        shape = RoundedCornerShape(20.dp),
                        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.92f)),
                    ) {
                        Text(
                            text = phrase.orEmpty(),
                            modifier = Modifier.padding(16.dp),
                            textAlign = TextAlign.Center,
                        )
                    }
                }
                Spacer(Modifier.height(20.dp))
                Box(contentAlignment = Alignment.Center) {
                    Text(
                        text = "✨ +$pointsBurst",
                        modifier = Modifier.graphicsLayer(alpha = sparkleAlpha.value),
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.Bold,
                    )
                    AvatarScene(
                        avatarId = state.home.avatarId,
                        equippedHatId = state.home.equippedHatId,
                        equippedScarfId = state.home.equippedScarfId,
                        equippedEyewearId = state.home.equippedEyewearId,
                        equippedGlovesId = state.home.equippedGlovesId,
                        equippedAccessoryId = state.home.equippedAccessoryId,
                        modifier = Modifier
                            .offset(y = hopOffset.value.dp)
                            .clickable { viewModel.requestPhrase() },
                    )
                }
                Spacer(Modifier.height(16.dp))
                Text(
                    text = state.home.avatarName,
                    style = MaterialTheme.typography.headlineMedium,
                )
                Text(
                    text = "Tap your companion for a catchphrase.",
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.75f),
                )
                Spacer(Modifier.weight(1f))
                ElevatedCard(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
                    colors = CardDefaults.elevatedCardColors(containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.94f)),
                ) {
                    Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Text("Gentle goal", style = MaterialTheme.typography.titleLarge)
                        LinearProgressIndicator(
                            progress = (state.home.todayCompletedCount / 3f).coerceIn(0f, 1f),
                            modifier = Modifier.fillMaxWidth(),
                        )
                        Text("${state.home.todayCompletedCount} of 3 tasks completed today")
                        Text("Three completed tasks makes today count toward the streak. Missing a day never removes what you've already done.")
                    }
                }
            }
        }
        AnimatedVisibility(
            visible = panelOpen,
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(top = 76.dp, end = 12.dp),
        ) {
            QuickTasksPanel(tasks = state.home.tasks.take(6), onComplete = viewModel::completeTask)
        }
    }
}

@Composable
private fun QuickTasksPanel(tasks: List<Task>, onComplete: (Task) -> Unit) {
    Card(
        modifier = Modifier.width(280.dp),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.96f)),
    ) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text("Quick task list", style = MaterialTheme.typography.titleLarge)
            tasks.forEach { task ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween,
                ) {
                    Column(Modifier.weight(1f)) {
                        Text(task.title, fontWeight = FontWeight.Medium)
                        Text("${task.pointValue} pts", color = MaterialTheme.colorScheme.primary)
                    }
                    IconButton(onClick = { onComplete(task) }) {
                        Icon(Icons.Rounded.CheckCircle, contentDescription = "Complete task")
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun TasksScreen(state: AppUiState, viewModel: MainViewModel) {
    var draft by remember { mutableStateOf(TaskDraft(tags = setOf("Self-care"))) }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(title = { Text("Master To-Do List") })
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            ElevatedCard(shape = RoundedCornerShape(24.dp)) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text("Add custom task", style = MaterialTheme.typography.titleLarge)
                    OutlinedTextField(
                        value = draft.title,
                        onValueChange = { draft = draft.copy(title = it) },
                        label = { Text("Task title") },
                        modifier = Modifier.fillMaxWidth(),
                    )
                    OutlinedTextField(
                        value = draft.notes,
                        onValueChange = { draft = draft.copy(notes = it) },
                        label = { Text("Optional note") },
                        modifier = Modifier.fillMaxWidth(),
                    )
                    OutlinedTextField(
                        value = draft.points.toString(),
                        onValueChange = { value -> draft = draft.copy(points = value.toIntOrNull() ?: draft.points) },
                        label = { Text("Points") },
                        modifier = Modifier.fillMaxWidth(),
                    )
                    Text("Tags")
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                        state.tagOptions.chunked(4).forEach { group ->
                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                group.forEach { tag ->
                                    FilterChip(
                                        selected = draft.tags.contains(tag),
                                        onClick = {
                                            draft = draft.copy(
                                                tags = if (draft.tags.contains(tag)) draft.tags - tag else draft.tags + tag,
                                            )
                                        },
                                        label = { Text(tag) },
                                    )
                                }
                            }
                        }
                    }
                    Button(onClick = { viewModel.addTask(draft); draft = TaskDraft(points = 10, tags = setOf("Self-care")) }) {
                        Text("Save task")
                    }
                }
            }
            ElevatedCard(shape = RoundedCornerShape(24.dp)) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("All tasks", style = MaterialTheme.typography.titleLarge)
                    state.home.tasks.forEach { task ->
                        TaskRow(task = task, onComplete = viewModel::completeTask)
                    }
                }
            }
        }
    }
}

@Composable
private fun TaskRow(task: Task, onComplete: (Task) -> Unit) {
    Card(shape = RoundedCornerShape(20.dp), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(task.title, fontWeight = FontWeight.SemiBold)
                if (task.notes.isNotBlank()) {
                    Text(task.notes, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f))
                }
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    task.tags.forEach { tag ->
                        AssistChip(onClick = {}, label = { Text(tag) })
                    }
                }
            }
            Column(horizontalAlignment = Alignment.End) {
                Text("${task.pointValue} pts", color = MaterialTheme.colorScheme.primary)
                IconButton(onClick = { onComplete(task) }) {
                    Icon(Icons.Rounded.CheckCircle, contentDescription = "Complete")
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ShopScreen(state: AppUiState, viewModel: MainViewModel) {
    Scaffold(topBar = { CenterAlignedTopAppBar(title = { Text("Cozy Shop") }) }) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            item {
                Text("Balance: ${state.home.pointsBalance} points", style = MaterialTheme.typography.titleLarge)
            }
            items(state.shopItems) { item ->
                ShopItemCard(item = item, onPurchase = { viewModel.purchase(item) }, onEquip = { viewModel.equip(item) })
            }
        }
    }
}

@Composable
private fun ShopItemCard(item: ShopItem, onPurchase: () -> Unit, onEquip: () -> Unit) {
    ElevatedCard(shape = RoundedCornerShape(24.dp)) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Column(Modifier.weight(1f)) {
                    Text(item.title, style = MaterialTheme.typography.titleLarge)
                    Text(item.description)
                }
                Text("${item.cost} pts", color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
            }
            Text("Track affinity: ${item.requiredTag}")
            when (item.type) {
                "background" -> Text("Preview: changes the home scene backdrop.")
                "phrase_pack" -> Text("Preview: adds new tap phrases for your companion.")
                "effect" -> Text("Preview: unlocks a new completion burst style.")
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                when {
                    !item.owned -> Button(onClick = onPurchase) { Text("Buy") }
                    item.type == "phrase_pack" -> Text("Owned", color = MaterialTheme.colorScheme.secondary)
                    item.equipped -> Text("Equipped", color = MaterialTheme.colorScheme.secondary)
                    else -> TextButton(onClick = onEquip) { Text("Equip") }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AvatarScreen(state: AppUiState, viewModel: MainViewModel) {
    var name by remember(state.home.avatarName) { mutableStateOf(state.home.avatarName) }

    Scaffold(topBar = { CenterAlignedTopAppBar(title = { Text("Avatar Room") }) }) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            ElevatedCard(shape = RoundedCornerShape(24.dp)) {
                Column(Modifier.padding(20.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    AvatarScene(
                        avatarId = state.home.avatarId,
                        equippedHatId = state.home.equippedHatId,
                        equippedScarfId = state.home.equippedScarfId,
                        equippedEyewearId = state.home.equippedEyewearId,
                        equippedGlovesId = state.home.equippedGlovesId,
                        equippedAccessoryId = state.home.equippedAccessoryId,
                    )
                    Spacer(Modifier.height(12.dp))
                    OutlinedTextField(value = name, onValueChange = { name = it }, label = { Text("Avatar name") })
                    Button(onClick = { viewModel.updateAvatarName(name) }, modifier = Modifier.padding(top = 12.dp)) {
                        Text("Save name")
                    }
                }
            }
            ElevatedCard(shape = RoundedCornerShape(24.dp)) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text("Choose a companion", style = MaterialTheme.typography.titleLarge)
                    state.avatars.forEach { avatar ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(20.dp))
                                .clickable { viewModel.chooseAvatar(avatar.id) }
                                .padding(12.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                                Box(
                                    modifier = Modifier
                                        .size(40.dp)
                                        .clip(CircleShape)
                                        .background(Color(avatar.accent)),
                                )
                                Text(avatar.title)
                            }
                            if (avatar.id == state.home.avatarId) {
                                Text("Selected", color = MaterialTheme.colorScheme.primary)
                            }
                        }
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SettingsScreen(state: AppUiState, viewModel: MainViewModel) {
    Scaffold(topBar = { CenterAlignedTopAppBar(title = { Text("Settings") }) }) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            ElevatedCard(shape = RoundedCornerShape(24.dp)) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text("Comfort", style = MaterialTheme.typography.titleLarge)
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Column(Modifier.weight(1f)) {
                            Text("Reward sound")
                            Text("A short soft beep on completion.", color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f))
                        }
                        Switch(checked = state.home.soundEnabled, onCheckedChange = { viewModel.toggleSound() })
                    }
                }
            }
            ElevatedCard(shape = RoundedCornerShape(24.dp)) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("About v0", style = MaterialTheme.typography.titleLarge)
                    Text("Local-only storage, a single master task list, gentle streaks, cozy avatar customization, and a small working shop built for expansion.")
                }
            }
        }
    }
}

@Composable
private fun AvatarScene(
    avatarId: String,
    equippedHatId: String? = null,
    equippedScarfId: String? = null,
    equippedEyewearId: String? = null,
    equippedGlovesId: String? = null,
    equippedAccessoryId: String? = null,
    modifier: Modifier = Modifier,
) {
    val bodyColor = when (avatarId) {
        "bear" -> Color(0xFF8D6E63)
        "bunny" -> Color(0xFFF0D8DF)
        else -> Color(0xFF4F6D7A)
    }
    val bellyColor = when (avatarId) {
        "bear" -> Color(0xFFEBD7C8)
        "bunny" -> Color(0xFFFFF7F9)
        else -> Color(0xFFF7F8FA)
    }

    Box(modifier = modifier.size(240.dp), contentAlignment = Alignment.Center) {
        Box(
            modifier = Modifier
                .size(210.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.22f)),
        )
        Box(
            modifier = Modifier
                .size(160.dp, 190.dp)
                .clip(RoundedCornerShape(80.dp))
                .background(bodyColor),
        ) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 18.dp)
                    .size(90.dp, 110.dp)
                    .clip(RoundedCornerShape(50.dp))
                    .background(bellyColor),
            )
        }
        Box(
            modifier = Modifier
                .offset(y = (-58).dp)
                .size(135.dp)
                .clip(CircleShape)
                .background(bodyColor),
        )
        if (avatarId != "penguin") {
            Row(
                modifier = Modifier.offset(y = (-110).dp),
                horizontalArrangement = Arrangement.spacedBy(48.dp),
            ) {
                Box(Modifier.size(28.dp).clip(CircleShape).background(bodyColor))
                Box(Modifier.size(28.dp).clip(CircleShape).background(bodyColor))
            }
        }
        Row(
            modifier = Modifier.offset(y = (-64).dp),
            horizontalArrangement = Arrangement.spacedBy(30.dp),
        ) {
            Box(Modifier.size(12.dp).clip(CircleShape).background(Color(0xFF23303A)))
            Box(Modifier.size(12.dp).clip(CircleShape).background(Color(0xFF23303A)))
        }
        Box(
            modifier = Modifier
                .offset(y = (-36).dp)
                .size(if (avatarId == "penguin") 16.dp else 14.dp)
                .clip(CircleShape)
                .background(if (avatarId == "penguin") Color(0xFFF2A572) else Color(0xFF52352C)),
        )
        if (equippedHatId != null) {
            Box(
                modifier = Modifier
                    .offset(y = (-102).dp)
                    .size(104.dp, 34.dp)
                    .clip(RoundedCornerShape(20.dp))
                    .background(Color(0xFF7A4B3B)),
            )
            Box(
                modifier = Modifier
                    .offset(y = (-126).dp)
                    .size(76.dp, 40.dp)
                    .clip(RoundedCornerShape(22.dp))
                    .background(Color(0xFF9A6652)),
            )
        }
        if (equippedScarfId != null) {
            Box(
                modifier = Modifier
                    .offset(y = 14.dp)
                    .size(120.dp, 28.dp)
                    .clip(RoundedCornerShape(18.dp))
                    .background(Color(0xFFD2B48C)),
            )
            Box(
                modifier = Modifier
                    .offset(x = 26.dp, y = 42.dp)
                    .rotate(12f)
                    .size(24.dp, 60.dp)
                    .clip(RoundedCornerShape(18.dp))
                    .background(Color(0xFFB2845D)),
            )
        }
        if (equippedEyewearId != null) {
            Row(
                modifier = Modifier.offset(y = (-62).dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Box(
                    Modifier
                        .size(24.dp)
                        .clip(CircleShape)
                        .border(3.dp, Color(0xFF46352F), CircleShape),
                )
                Box(Modifier.size(16.dp, 3.dp).background(Color(0xFF46352F)))
                Box(
                    Modifier
                        .size(24.dp)
                        .clip(CircleShape)
                        .border(3.dp, Color(0xFF46352F), CircleShape),
                )
            }
        }
        if (equippedGlovesId != null) {
            Row(
                modifier = Modifier.offset(y = 42.dp),
                horizontalArrangement = Arrangement.spacedBy(120.dp),
            ) {
                Box(Modifier.size(18.dp, 26.dp).clip(RoundedCornerShape(12.dp)).background(Color(0xFFE6D0CF)))
                Box(Modifier.size(18.dp, 26.dp).clip(RoundedCornerShape(12.dp)).background(Color(0xFFE6D0CF)))
            }
        }
        if (equippedAccessoryId != null) {
            Box(
                modifier = Modifier
                    .offset(x = 40.dp, y = 2.dp)
                    .size(18.dp)
                    .clip(CircleShape)
                    .background(Color(0xFFE0B646)),
            )
        }
    }
}

@Composable
private fun CozyStat(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, fontWeight = FontWeight.Bold, fontSize = 18.sp)
        Text(label, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f))
    }
}

private fun backgroundBrush(backgroundId: String): Brush =
    when (backgroundId) {
        "twilight_window" -> Brush.linearGradient(
            colors = listOf(Color(0xFF3A4C65), Color(0xFF7A5B6E), Color(0xFFD6B18C)),
            start = Offset.Zero,
            end = Offset(900f, 1600f),
        )
        "winter_market" -> Brush.linearGradient(
            colors = listOf(Color(0xFF46545F), Color(0xFF7C5B3F), Color(0xFFE0C39C)),
            start = Offset.Zero,
            end = Offset(900f, 1600f),
        )
        else -> Brush.linearGradient(
            colors = listOf(Color(0xFF56738A), Color(0xFF9CB1BE), Color(0xFFE2C39A)),
            start = Offset.Zero,
            end = Offset(900f, 1600f),
        )
    }
