abstract class StepReviewState {
  @override
  List<Object> get props => [];
}

class WithoutDataState extends StepReviewState {
  @override
  String toString() => 'StepEnterAccountState:DeletedState';
}

class WithDataState extends StepReviewState {
  @override
  String toString() => 'StepEnterAccountState:FullState';
}
