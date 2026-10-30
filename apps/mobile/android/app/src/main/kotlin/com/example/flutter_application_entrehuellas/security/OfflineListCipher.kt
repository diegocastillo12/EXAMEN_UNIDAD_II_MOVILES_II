package com.example.flutter_application_entrehuellas.security

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import java.security.MessageDigest
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** Non-exportable AES keys live only in AndroidKeyStore, never in Dart or files. */
class OfflineListCipher internal constructor(
    private val aliasPrefix: String = "entrehuellas.offline.saved-list.v2."
) {
    private val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    internal fun alias(owner: String): String {
        require(Regex("^[a-zA-Z0-9_-]+$").matches(owner))
        val digest = MessageDigest.getInstance("SHA-256").digest(owner.toByteArray(Charsets.UTF_8))
        return aliasPrefix + digest.joinToString("") { "%02x".format(it) }
    }

    private fun key(owner: String, create: Boolean): SecretKey {
        val alias = alias(owner)
        val existing = store.getKey(alias, null) as? SecretKey
        if (existing != null) return existing
        check(create) { "Offline key unavailable" }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        generator.init(KeyGenParameterSpec.Builder(alias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
            .setKeySize(256)
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setRandomizedEncryptionRequired(true)
            .build())
        return generator.generateKey()
    }

    private fun aad(owner: String) = "entrehuellas:offline_saved_cases:v2:$owner".toByteArray(Charsets.UTF_8)

    @Synchronized
    fun encrypt(owner: String, plaintext: ByteArray): ByteArray {
        require(plaintext.size <= 4 * 1024 * 1024)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        // Android generates a fresh random 96-bit IV for every initialization.
        cipher.init(Cipher.ENCRYPT_MODE, key(owner, create = true))
        cipher.updateAAD(aad(owner))
        val iv = cipher.iv
        check(iv.size == 12)
        // doFinal includes the 128-bit authentication tag after the ciphertext.
        return iv + cipher.doFinal(plaintext)
    }

    @Synchronized
    fun decrypt(owner: String, sealed: ByteArray): ByteArray {
        require(sealed.size in 28..(4 * 1024 * 1024 + 28))
        val iv = sealed.copyOfRange(0, 12)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        // A missing key must fail, never silently generate a replacement on read.
        cipher.init(Cipher.DECRYPT_MODE, key(owner, create = false), GCMParameterSpec(128, iv))
        cipher.updateAAD(aad(owner))
        return cipher.doFinal(sealed, 12, sealed.size - 12)
    }

    @Synchronized
    fun deleteKeys() {
        val aliases = store.aliases().toList().filter { it.startsWith(aliasPrefix) }
        aliases.forEach { store.deleteEntry(it) }
    }
}
