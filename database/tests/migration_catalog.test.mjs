import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { test } from 'node:test';

const database = new URL('../', import.meta.url);
const migrations = new URL('../../supabase/migrations/', import.meta.url);

test('Independent feature plans and migrations have unique deployment versions', async () => {
  const versions = new Map();
  for (const name of await readdir(new URL('migration_plans/', database))) {
    if (!name.endsWith('.json')) continue;
    const plan = JSON.parse(await readFile(new URL(`migration_plans/${name}`, database), 'utf8'));
    assert.equal(versions.has(plan.version), false, `${name} duplicates ${versions.get(plan.version)}`);
    versions.set(plan.version, name);
    await readFile(new URL(`${plan.version}_${plan.name}.sql`, migrations));
  }
  const deployed = new Map();
  for (const name of await readdir(migrations)) {
    if (!name.endsWith('.sql')) continue;
    const version = name.split('_')[0];
    assert.equal(deployed.has(version), false, `${name} duplicates ${deployed.get(version)}`);
    deployed.set(version, name);
  }
});

test('SQL source numbers remain global across schema directories', async () => {
  const numbers = new Map();
  for (const category of ['extensions', 'types', 'tables', 'indexes', 'functions', 'triggers', 'views', 'policies', 'grants']) {
    for (const name of await readdir(new URL(`${category}/`, database))) {
      if (!name.endsWith('.sql')) continue;
      const number = Number(name.split('_')[0]);
      assert.equal(numbers.has(number), false, `${category}/${name} duplicates ${numbers.get(number)}`);
      numbers.set(number, `${category}/${name}`);
    }
  }
});
