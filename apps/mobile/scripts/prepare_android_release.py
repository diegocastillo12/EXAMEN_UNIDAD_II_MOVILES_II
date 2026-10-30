"""Validate CI inputs without printing credentials, then create ignored build files."""

import base64
import json
import os
from pathlib import Path
from urllib.parse import urlsplit


def prepare():
    required = (
        "MOBILE_CONFIG_JSON", "ANDROID_KEYSTORE_BASE64", "ANDROID_KEYSTORE_PATH",
        "ANDROID_KEYSTORE_PASSWORD", "ANDROID_KEY_ALIAS", "ANDROID_KEY_PASSWORD",
    )
    missing = [name for name in required if not os.environ.get(name, "").strip()]
    if missing:
        raise ValueError("Missing GitHub Actions secrets/environment: " + ", ".join(missing))
    config = json.loads(os.environ["MOBILE_CONFIG_JSON"])
    if not isinstance(config, dict):
        raise ValueError("MOBILE_CONFIG_JSON must be a JSON object")
    allowed = {
        "SUPABASE_URL", "SUPABASE_PUBLISHABLE_KEY", "EMAIL_OTP_VALIDITY_MINUTES",
        "PUBLIC_CASE_WEB_URL", "PUBLIC_CASE_WEB_READY", "MAP_TILE_URL", "PLACE_SEARCH_URL",
    }
    if set(config) - allowed:
        raise ValueError("MOBILE_CONFIG_JSON contains unsupported keys; use the release example")
    url = urlsplit(config.get("SUPABASE_URL", ""))
    if (url.scheme != "https" or not url.hostname or "TU_" in config.get("SUPABASE_URL", "") or url.username or url.password
            or url.query or url.fragment or url.path not in ("", "/")):
        raise ValueError("SUPABASE_URL must be an HTTPS origin")
    key = config.get("SUPABASE_PUBLISHABLE_KEY", "")
    if not isinstance(key, str) or not key.startswith("sb_publishable_") or len(key) <= 15 or "TU_" in key or key != key.strip():
        raise ValueError("SUPABASE_PUBLISHABLE_KEY must be a public sb_publishable_ key")
    if type(config.get("PUBLIC_CASE_WEB_READY")) is not bool:
        raise ValueError("PUBLIC_CASE_WEB_READY must be an explicit JSON boolean")
    for name in ("PUBLIC_CASE_WEB_URL", "MAP_TILE_URL", "PLACE_SEARCH_URL"):
        value = config.get(name)
        if value is None and name == "PLACE_SEARCH_URL":
            continue
        if not isinstance(value, str) or not value.strip() or "API_KEY" in value or "TU_" in value:
            raise ValueError(name + " must be configured without example placeholders")
        endpoint = urlsplit(value)
        if endpoint.scheme != "https" or not endpoint.hostname or endpoint.username or endpoint.password:
            raise ValueError(name + " must use HTTPS without embedded credentials")
    keystore = base64.b64decode(os.environ["ANDROID_KEYSTORE_BASE64"], validate=True)
    if not keystore:
        raise ValueError("ANDROID_KEYSTORE_BASE64 is empty")
    destination = Path(os.environ["ANDROID_KEYSTORE_PATH"])
    destination.write_bytes(keystore)
    destination.chmod(0o600)
    config_path = Path("config/release.local.json")
    config_path.parent.mkdir(exist_ok=True)
    config_path.write_text(json.dumps(config), encoding="utf-8")
    config_path.chmod(0o600)
    print("Android release configuration prepared; credential values omitted.")


if __name__ == "__main__":
    try:
        prepare()
    except Exception as error:
        # JSON/base64 parsers can include input in their messages.
        message = str(error) if isinstance(error, ValueError) and type(error) is ValueError else type(error).__name__
        raise SystemExit("Release configuration failed: " + message)
