abstract class StepReviewState {
  @override
  List<Object> get props => [];
}

class WithoutDataState extends StepReviewState {
  @override
  String toString() => 'StepReviewState:WithoutDataState';
}

class WithDataState extends StepReviewState {
  @override
  String toString() => 'StepReviewState:WithDataState';
}
