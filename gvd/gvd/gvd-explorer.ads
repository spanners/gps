with Gtk.Ctree; use Gtk.Ctree;
with Gtk.Widget; use Gtk.Widget;

package Odd.Explorer is

   type Position_Type is record
      Line, Column, Index : Natural;
   end record;

   type Explorer_Handler is access
     procedure
       (Widget   : access Gtk_Widget_Record'Class;
        Position : Position_Type);
   --  Handler called when an item is selected in the tree.
   --  Index is the position in the buffer when the selected entity
   --  starts.
   --  Widget is the Window parameter given to Explore below.

   function Explore
     (Window  : access Gtk_Widget_Record'Class;
      Buffer  : String;
      Handler : Explorer_Handler := null) return Gtk_Ctree;

end Odd.Explorer;
