package com.befit_fitness.app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle

/**
 * Opened by Health Connect when the user taps BeFit's privacy policy link
 * (ACTION_SHOW_PERMISSIONS_RATIONALE on Android 13 and below,
 * VIEW_PERMISSION_USAGE via the activity-alias on Android 14+).
 * Opens the policy in the browser and closes.
 */
class HealthPrivacyPolicyActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val url = getString(R.string.health_privacy_policy_url)
        try {
            startActivity(
                Intent(Intent.ACTION_VIEW, Uri.parse(url))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        } catch (_: ActivityNotFoundException) {
            // No browser installed; nothing else to show.
        }
        finish()
    }
}
