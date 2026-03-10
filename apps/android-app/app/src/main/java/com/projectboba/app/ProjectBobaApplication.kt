package com.projectboba.app

import android.app.Application
import com.projectboba.app.core.AppContainer

class ProjectBobaApplication : Application() {
    lateinit var container: AppContainer
        private set

    override fun onCreate() {
        super.onCreate()
        container = AppContainer(this)
    }
}
