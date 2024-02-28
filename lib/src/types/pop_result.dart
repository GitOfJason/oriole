enum PopResult {
  /// The pop end successfully
  popped,

  /// Cannot pop
  notPopped,

  /// The Can pop in the middleware returns false
  notAllowedToPop,

  /// This means that the navigator has a [PopupRoute] and it was dismissed and no other page was popped
  popupDismissed,
}

/// Use this to define what to do when page already is in the stack
enum PageAlreadyExistAction {
  /// Remove the page from the stack
  remove,

  /// Bring the page to the top of the stack, if the page has any children in the stack, bring the first child to the top
  bringToTop,

  /// Just bring the page to the top of the stack, and ignore any children of this page in the stack
  ignoreChildrenAndBringToTop,
}
