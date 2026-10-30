import { HttpCaseRepository } from '#shared/features/case_reader/data/http_case_repository';
import { ReaderFailure } from '#shared/features/case_reader/domain/case';
import { ReadCase } from '#shared/features/case_reader/domain/read_case';
import { ReaderViewModel } from '#shared/features/case_reader/presentation/reader_view_model';
import type { PublicCase } from '#shared/features/case_reader/domain/case';
export default defineNuxtPlugin(() => {
  const requestFetch = useRequestFetch();
  const repository = new HttpCaseRepository(async (path, options) => {
    try { return await requestFetch(path, { signal: options.signal || undefined, cache: 'no-store', credentials: 'omit', retry: 0 }); }
    catch (error) {
      const status = error && typeof error === 'object' && 'statusCode' in error ? error.statusCode : null;
      if (status === 404) return { state: 'unavailable' };
      throw new ReaderFailure(status === 429 ? 'rate_limited' : 'unavailable');
    }
  });
  const read = new ReadCase(repository);
  return { provide: {
    readPublicCase: (slug: string) => read.execute(slug),
    readerModel: (initial: PublicCase | null, slug: string, failed: boolean) => new ReaderViewModel(read, initial, slug, failed),
  } };
});
