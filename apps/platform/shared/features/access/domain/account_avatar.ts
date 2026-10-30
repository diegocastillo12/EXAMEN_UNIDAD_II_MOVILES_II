export interface AccountAvatarRepository { avatar():Promise<Uint8Array|null>; }
export class ReadAccountAvatar {
  constructor(private readonly repository:AccountAvatarRepository) {}
  execute() { return this.repository.avatar(); }
}
