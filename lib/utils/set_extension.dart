extension SetExtension<T> on Set<T> {
  int indexOf(T el) {
    if (contains(el)) {
      int idx = 0;
      for (final e in this) {
        if (e == el) {
          return idx;
        }
        idx++;
      }
    }
    return -1;
  }
}
