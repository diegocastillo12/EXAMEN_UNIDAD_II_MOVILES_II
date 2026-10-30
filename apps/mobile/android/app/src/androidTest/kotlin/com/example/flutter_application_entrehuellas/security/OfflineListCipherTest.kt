package com.example.flutter_application_entrehuellas.security

import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.After
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith
import java.security.KeyStore
import java.util.UUID
import javax.crypto.AEADBadTagException

/** Uses real AndroidKeyStore on the emulator; no fake cipher or embedded key. */
@RunWith(AndroidJUnit4::class)
class OfflineListCipherTest {
    private val owner = "crypto-test-" + UUID.randomUUID().toString()
    private val cipher = OfflineListCipher()
    private val plaintext = "{\"name\":\"Cliente Prueba\"}".toByteArray(Charsets.UTF_8)

    @After
    fun removeOnlyTestKey() {
        KeyStore.getInstance("AndroidKeyStore").apply { load(null); deleteEntry(cipher.alias(owner)) }
    }

    @Test
    fun freshIvAndPersistentNonExportableKey() {
        val first = cipher.encrypt(owner, plaintext)
        val second = cipher.encrypt(owner, plaintext)
        assertFalse(first.copyOfRange(0, 12).contentEquals(second.copyOfRange(0, 12)))
        assertFalse(String(first, Charsets.UTF_8).contains("Cliente Prueba"))
        assertArrayEquals(plaintext, OfflineListCipher().decrypt(owner, first))
        assertArrayEquals(plaintext, cipher.decrypt(owner, second))
        val key = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }.getKey(cipher.alias(owner), null)
        assertEquals("AES", key.algorithm)
        assertNull(key.encoded)
    }

    @Test
    fun changingCiphertextOrIvFailsAuthentication() {
        val original = cipher.encrypt(owner, plaintext)
        for (index in listOf(0, original.lastIndex)) {
            val altered = original.copyOf()
            altered[index] = (altered[index].toInt() xor 1).toByte()
            try {
                cipher.decrypt(owner, altered)
                fail("Altered GCM data must fail")
            } catch (_: AEADBadTagException) {
                // Expected: no unauthenticated plaintext is returned.
            }
        }
    }

    @Test
    fun missingAccountKeyIsNotCreatedOnRead() {
        val original = cipher.encrypt(owner, plaintext)
        val other = "crypto-missing-" + UUID.randomUUID().toString()
        try {
            cipher.decrypt(other, original)
            fail("Different account must not decrypt")
        } catch (_: IllegalStateException) {
            val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
            assertFalse(store.containsAlias(cipher.alias(other)))
        }
    }

    @Test
    fun deletionRemovesScopedKeysAndOldCiphertextCannotBeRead() {
        // Isolated namespace: this test must not delete the user's real key.
        val testCipher = OfflineListCipher("entrehuellas.test-clear." + UUID.randomUUID() + ".")
        val first = testCipher.encrypt(owner, plaintext)
        testCipher.encrypt(owner + "-other", plaintext)
        testCipher.deleteKeys()
        val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        assertFalse(store.containsAlias(testCipher.alias(owner)))
        assertFalse(store.containsAlias(testCipher.alias(owner + "-other")))
        try {
            testCipher.decrypt(owner, first)
            fail("Deleted key must not be recreated on read")
        } catch (_: IllegalStateException) {
            assertFalse(store.containsAlias(testCipher.alias(owner)))
        }
        testCipher.deleteKeys()
    }
}
