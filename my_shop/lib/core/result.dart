sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) ok, required R Function(Object, StackTrace?) err});
}
class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
  @override
  R when<R>({required R Function(T p1) ok, required R Function(Object, StackTrace?) err}) => ok(value);
}
class Err<T> extends Result<T> {
  final Object error;
  final StackTrace? st;
  const Err(this.error, [this.st]);
  @override
  R when<R>({required R Function(T p1) ok, required R Function(Object, StackTrace?) err}) => err(error, st);
}