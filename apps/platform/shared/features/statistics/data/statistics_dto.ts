import { StatisticsFailure, statisticsPeriod } from '../domain/statistics.ts';
import type { PilotStatistics } from '../domain/statistics.ts';
export function statisticsDto(value: unknown): PilotStatistics {
  try {
    const raw = value as Record<string, unknown>;
    if (!raw || raw.timezone !== 'America/Lima') throw Error();
    const period = raw.period as { from?: unknown; to?: unknown };
    const count = (key: string) => {
      const n = raw[key];
      if (typeof n !== 'number' || !Number.isSafeInteger(n) || n < 0) throw Error();
      return n;
    };
    return Object.freeze({ period: statisticsPeriod(period?.from, period?.to), timezone: 'America/Lima',
      publishedLost: count('publishedLost'), publishedFound: count('publishedFound'), sightings: count('sightings'),
      recovered: count('recovered'), cancelled: count('cancelled'), archived: count('archived'), reports: count('reports') });
  } catch { throw new StatisticsFailure('unavailable'); }
}
