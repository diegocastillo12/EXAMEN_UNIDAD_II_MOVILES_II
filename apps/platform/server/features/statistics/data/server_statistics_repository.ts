import { StatisticsFailure } from '../../../../shared/features/statistics/domain/statistics.ts';
import type { StatisticsRepository, StatisticsPeriod } from '../../../../shared/features/statistics/domain/statistics.ts';
import { statisticsDto } from '../../../../shared/features/statistics/data/statistics_dto.ts';
import type { StatisticsSource } from './statistics_source.ts';
export class ServerStatisticsRepository implements StatisticsRepository {
  constructor(private readonly source: StatisticsSource, private readonly actor: string) {}
  async canRead() {
    try { return await this.source.rpc('require_platform_administrator', {}) === this.actor; }
    catch (error) { if (error instanceof StatisticsFailure && error.kind === 'forbidden') return false; throw error; }
  }
  async read(period: StatisticsPeriod) {
    const result = statisticsDto(await this.source.rpc('read_pilot_statistics', { p_from: period.from, p_to: period.to }));
    if (result.period.from !== period.from || result.period.to !== period.to) throw new StatisticsFailure('unavailable');
    return result;
  }
}
