import { configuration } from '../infrastructure/config';
import { SupabaseCaseRepository } from '../features/case_reader/data/supabase_case_repository';
import { SupabaseCaseDataSource } from '../features/case_reader/data/supabase_case_data_source';
import { ReadCase, ReadCasePhoto } from '../../shared/features/case_reader/domain/read_case';
export function caseReader() {
  const config = configuration(process.env);
  const repository = new SupabaseCaseRepository(new SupabaseCaseDataSource(config));
  return { read: new ReadCase(repository), photo: new ReadCasePhoto(repository) };
}
