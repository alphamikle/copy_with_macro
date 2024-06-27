String constructorName(String originalName) {
  if (originalName == '') {
    return 'a default (empty) constructor';
  }
  return 'a constructor with name ".$originalName"';
}
