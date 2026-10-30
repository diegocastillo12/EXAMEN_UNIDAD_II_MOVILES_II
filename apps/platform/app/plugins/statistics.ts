import { HttpStatisticsRepository } from '#shared/features/statistics/data/http_statistics_repository';
import { ReadPilotStatistics, ReadStatisticsAccess } from '#shared/features/statistics/domain/statistics';
import { StatisticsViewModel } from '#shared/features/statistics/presentation/statistics_view_model';
export default defineNuxtPlugin(() => ({ provide: { statisticsModel: (actor: string) => {
  const repository = new HttpStatisticsRepository(actor);
  const today = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Lima', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date());
  return new StatisticsViewModel(new ReadStatisticsAccess(repository), new ReadPilotStatistics(repository), today);
} } }));
