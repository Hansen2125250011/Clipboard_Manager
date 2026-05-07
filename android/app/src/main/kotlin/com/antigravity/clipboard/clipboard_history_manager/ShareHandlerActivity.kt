package com.antigravity.clipboard.clipboard_history_manager

import android.app.Activity
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.os.Bundle
import android.widget.Toast
import android.content.ClipboardManager
import android.content.ClipData
import java.text.SimpleDateFormat
import java.util.*

class ShareHandlerActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        handleIntent(intent)
        
        // Finish immediately so the user never sees this activity
        finish()
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            val text = intent.getStringExtra(Intent.EXTRA_TEXT)
            if (text != null) {
                saveToDatabase(text)
                copyToClipboard(text)
                showToast("Berhasil disimpan ke riwayat & clipboard")
            }
        }
    }

    private fun saveToDatabase(content: String) {
        try {
            val dbPath = getDatabasePath("clipboard_history.db")
            // Ensure DB is opened or created correctly
            val db = SQLiteDatabase.openDatabase(dbPath.absolutePath, null, SQLiteDatabase.OPEN_READWRITE)
            
            // Check for duplicates (last entry)
            val cursor = db.query("clips", arrayOf("content"), null, null, null, null, "timestamp DESC", "1")
            var isDuplicate = false
            if (cursor.moveToFirst()) {
                val lastContent = cursor.getString(0)
                if (lastContent == content) {
                    isDuplicate = true
                }
            }
            cursor.close()

            if (!isDuplicate) {
                val values = ContentValues().apply {
                    put("content", content)
                    put("timestamp", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).format(Date()))
                    put("isFavorite", 0)
                    put("isSynced", 0) // Tag as unsynced for the Flutter app to pick up
                }
                db.insert("clips", null, values)
            }
            db.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun copyToClipboard(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Clipboard Manager", text)
        clipboard.setPrimaryClip(clip)
    }

    private fun showToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
}
