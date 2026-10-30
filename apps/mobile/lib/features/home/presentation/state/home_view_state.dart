enum HomeSection { home, explore, pets }

class HomeViewState {
  const HomeViewState({
    this.section = HomeSection.home,
    this.refreshError = false,
    this.noticeId = 0,
  });
  final HomeSection section;
  final bool refreshError;
  final int noticeId;
}
