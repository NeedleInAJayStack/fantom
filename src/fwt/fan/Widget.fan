//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Jun 08  Brian Frank  Creation
//

//
// TODO:
// Widgets:
//   - ScrollPane
//   - BorderPane
//   - ProgressBar
//   - Dialogs
//   - FileDialog
//   - DirDialog
// Eventing
//   - mouse eventing (have up/down, need move)
//   - focus management
// Graphics:
//   - affine transformations
//

**
** Widget is the base class for all UI widgets.
**
@serializable @collection
abstract class Widget
{

//////////////////////////////////////////////////////////////////////////
// State
//////////////////////////////////////////////////////////////////////////

  **
  ** Enabled is used to control whether this widget can
  ** accept user input.  Disabled controls are "grayed out".
  **
  native Bool enabled

  **
  ** Controls whether this widget is visible or hidden.
  **
  native Bool visible

//////////////////////////////////////////////////////////////////////////
// Eventing
//////////////////////////////////////////////////////////////////////////

  **
  ** Callback for key pressed event on this widget.  To cease propagation
  ** and processing of the event, then [consume]`Event.consume` it.
  **
  ** Event id fired:
  **   - `EventId.keyDown`
  **
  ** Event fields:
  **   - `Event.keyChar`: unicode character represented by key event
  **   - `Event.key`: key code including the modifiers
  **
  @transient readonly EventListeners onKeyDown := EventListeners()
    { onModify = &checkKeyListeners }
  internal native Void checkKeyListeners()

  **
  ** Callback for key released events on this widget.  To cease propagation
  ** and processing of the event, then [consume]`Event.consume` it.
  **
  ** Event id fired:
  **   - `EventId.keyUp`
  **
  ** Event fields:
  **   - `Event.keyChar`: unicode character represented by key event
  **   - `Event.key`: key code including the modifiers
  **
  @transient readonly EventListeners onKeyUp := EventListeners()
    { onModify = &checkKeyListeners }

  **
  ** Callback for mouse button pressed event on this widget.
  **
  ** Event id fired:
  **   - `EventId.mouseDown`
  **
  ** Event fields:
  **   - `Event.pos`
  **   - `Event.count`
  **   - `Event.key`: key modifiers
  **
  @transient readonly EventListeners onMouseDown := EventListeners()

  **
  ** Callback for mouse button released event on this widget.
  **
  ** Event id fired:
  **   - `EventId.mouseUp`
  **
  ** Event fields:
  **   - `Event.pos`
  **   - `Event.count`
  **   - `Event.key`: key modifiers
  **
  @transient readonly EventListeners onMouseUp := EventListeners()

  **
  ** Callback for focus gained event on this widget.
  **
  ** Event id fired:
  **   - `EventId.focus`
  **
  ** Event fields:
  **   - none
  **
  @transient readonly EventListeners onFocus := EventListeners()
    { onModify = &checkFocusListeners }
  internal native Void checkFocusListeners()

  **
  ** Callback for focus lost event on this widget.
  **
  ** Event id fired:
  **   - `EventId.blur`
  **
  ** Event fields:
  **   - none
  **
  @transient readonly EventListeners onBlur := EventListeners()
    { onModify = &checkFocusListeners }

//////////////////////////////////////////////////////////////////////////
// Focus
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this widget is the focused widget which
  ** is currently receiving all keyboard input.
  **
  native Bool hasFocus()

  **
  ** Attempt for this widget to take the keyboard focus.
  **
  native Void focus()

//////////////////////////////////////////////////////////////////////////
// Bounds
//////////////////////////////////////////////////////////////////////////

  **
  ** Position of this widget relative to its parent.
  ** If this a window, this is the position on the screen.
  **
  @transient
  native Point pos

  **
  ** Size of this widget.
  **
  @transient
  native Size size

  **
  ** Position and size of this widget relative to its parent.
  ** If this a window, this is the position on the screen.
  **
  Rect bounds
  {
    get { return Rect.makePosSize(pos, size) }
    set { pos = val.pos; size = val.size }
  }

  **
  ** Get the position of this widget on the screen coordinate's
  ** system.  If not on mounted on the screen then return null.
  **
  native Point posOnDisplay()

//////////////////////////////////////////////////////////////////////////
// Widget Tree
//////////////////////////////////////////////////////////////////////////

  **
  ** Get this widget's parent or null if not mounted.
  **
  @transient readonly Widget parent
  internal Void setParent(Widget p) { parent = p } // for Window.make

  **
  ** Get this widget's parent window or null if not
  ** mounted under a Window widget.
  **
  Window window()
  {
    x := this
    while (x != null)
    {
      if (x is Window) return (Window)x
      x = x.parent
    }
    return null
  }

  **
  ** Iterate the children widgets.
  **
  Void each(|Widget w, Int i| f)
  {
    kids.each(f)
  }

  **
  ** Get the children widgets.
  **
  Widget[] children() { return kids.ro }

  **
  ** Add a child widget.  If child is null, then do nothing.
  ** If child is already parented throw ArgErr.  Return this.
  **
  virtual This add(Widget child)
  {
    if (child == null) return this
    if (child.parent != null)
      throw ArgErr("Child already parented: $child")
    child.parent = this
    kids.add(child)
    try { child.attach } catch (Err e) { e.trace }
    return this
  }

  **
  ** Remove a child widget.  If child is null, then do
  ** nothing.  If this widget is not the child's current
  ** parent throw ArgErr.  Return this.
  **
  virtual This remove(Widget child)
  {
    if (child == null) return this
    try { child.detach } catch (Err e) { e.trace }
    if (kids.removeSame(child) == null)
      throw ArgErr("not my child: $child")
    child.parent = null
    return this
  }

  **
  ** Remove all child widgets.  Return this.
  **
  virtual This removeAll()
  {
    kids.dup.each |Widget kid| { remove(kid) }
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Layout
//////////////////////////////////////////////////////////////////////////

  **
  ** Relayout this widget.  This method is called when something
  ** has changed and we need to recompute the layout of this
  ** widget's children.
  **
  native Void relayout()

  **
  ** Compute the preferred size of this widget.  The hints indicate
  ** constraints the widget should consider in its calculations.
  ** If no constraints are known for width, then 'hints.w' will be
  ** null.  If no constraints are known for height, then 'hints.h'
  ** will be null.
  **
  virtual native Size prefSize(Hints hints := Hints.def)

  **
  ** Handle the layout event.  The method is only called Pane
  ** containers.  Custom panes must override this method to
  ** set the bounds on all their children.
  **
  virtual Void onLayout() {}

//////////////////////////////////////////////////////////////////////////
// Painting
//////////////////////////////////////////////////////////////////////////

  **
  ** Repaint this widget.  If the dirty rectangle is null,
  ** then the whole widget is repainted.
  **
  native Void repaint(Rect dirty := null)

  **
  ** This callback is invoked when the widget should be repainted.
  ** The graphics context is initialized at the widget's origin
  ** with the clip bounds set to the widget's size.
  **
  virtual Void onPaint(Graphics g)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Peer
//////////////////////////////////////////////////////////////////////////

  ** Is this widget attached to a native peer?
  private native Bool attached()

  ** Attach to a native peer
  private native Void attach()

  ** Detach from native peer
  private native Void detach()

//////////////////////////////////////////////////////////////////////////
// Private
//////////////////////////////////////////////////////////////////////////

  @transient
  internal Widget[] kids := Widget[,]

}