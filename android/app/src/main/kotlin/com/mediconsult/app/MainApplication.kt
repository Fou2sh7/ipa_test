package com.mediconsult.app

import android.app.Application
import android.util.Log
import java.lang.Thread.UncaughtExceptionHandler

class MainApplication : Application() {
    
    private val defaultExceptionHandler = Thread.getDefaultUncaughtExceptionHandler()
    
    override fun onCreate() {
        super.onCreate()
        
        // Set up global exception handler to catch Google Sign-In errors
        Thread.setDefaultUncaughtExceptionHandler { thread, exception ->
            // Check if it's a Google Sign-In related error
            val errorMessage = exception.message ?: ""
            val causeMessage = exception.cause?.message ?: ""
            val stackTrace = exception.stackTraceToString()
            
            if (errorMessage.contains("SignInHubActivity", ignoreCase = true) || 
                causeMessage.contains("SignInHubActivity", ignoreCase = true) ||
                stackTrace.contains("SignInHubActivity", ignoreCase = true) ||
                (errorMessage.contains("NullPointerException", ignoreCase = true) && 
                 stackTrace.contains("com.google.android.gms.auth", ignoreCase = true))) {
                // Google Sign-In is not configured, but we don't use it
                // Log the error but don't crash the app
                Log.w("MainApplication", "Google Sign-In error caught and ignored: ${exception.message}", exception)
                // Don't crash - just return
                return@setDefaultUncaughtExceptionHandler
            }
            
            // For other exceptions, use default handler
            defaultExceptionHandler?.uncaughtException(thread, exception)
        }
    }
}

