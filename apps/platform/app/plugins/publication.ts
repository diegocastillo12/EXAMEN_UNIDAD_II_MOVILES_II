import {ReadCasePublication}from'#shared/features/recovery/domain/recovery';
import {HttpRecoveryRepository}from'#shared/features/recovery/data/http_recovery_repository';
import {PublicationViewModel}from'#shared/features/recovery/presentation/publication_view_model';
export default defineNuxtPlugin(()=>({provide:{publicationModel:(actor:string)=>new PublicationViewModel(new ReadCasePublication(new HttpRecoveryRepository(actor)))}}));
