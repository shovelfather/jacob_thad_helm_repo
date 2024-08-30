#!/usr/bin/env bash

DECISIONS_ADMINISTRATOR_EMAIL="{ADMIN_EMAIL}"
DECISIONS_ADMINISTRATOR_PASSWORD="{ADMIN_PASS}"

psql -c 'UPDATE entity_account SET password_hash = decode((select encode(sha256(\'$DECISIONS_ADMINISTRATOR_PASSWORD\'::bytea), \'hex\')), \'hex\') WHERE email_address = \'admin@decisions.com\';' psql -c 'UPDATE entity_account SET email_address = \'$DECISIONS_ADMINISTRATOR_EMAIL\' WHERE email_address = \'admin@decisions.com\';'
