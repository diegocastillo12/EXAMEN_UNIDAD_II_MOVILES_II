export type StatisticsIssue = 'invalid' | 'unauthenticated' | 'forbidden' | 'conflict' | 'unavailable';
export class StatisticsFailure extends Error {
  constructor(readonly kind: StatisticsIssue) { super(kind); }
}
export type StatisticsPeriod = Readonly<{ from: string; to: string }>;
export type PilotStatistics = Readonly<{
  period: StatisticsPeriod; timezone: 'America/Lima';
  publishedLost: number; publishedFound: number; sightings: number;
  recovered: number; cancelled: number; archived: number; reports: number;
}>;
export function statisticsPeriod(from: unknown, to: unknown): StatisticsPeriod {
  const day = (value: unknown): value is string => typeof value === 'string' && /^20\d{2}-\d{2}-\d{2}$/.test(value) &&
    Number.isFinite(Date.parse(value)) && new Date(value).toISOString().slice(0, 10) === value;
  if (!day(from) || !day(to) || from > to || (Date.parse(to) - Date.parse(from)) / 86400000 >= 366) throw new StatisticsFailure('invalid');
  return Object.freeze({ from, to });
}
export interface StatisticsRepository {
  canRead(): Promise<boolean>;
  read(period: StatisticsPeriod): Promise<PilotStatistics>;
}
export class ReadStatisticsAccess {
  constructor(private readonly repository: StatisticsRepository) {}
  execute() { return this.repository.canRead(); }
}
export class ReadPilotStatistics {
  constructor(private readonly repository: StatisticsRepository) {}
  execute(period: StatisticsPeriod) { return this.repository.read(statisticsPeriod(period?.from, period?.to)); }
}
