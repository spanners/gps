-----------------------------------------------------------------------
--               GtkAda - Ada95 binding for Gtk+/Gnome               --
--                                                                   --
--                Copyright (C) 2001-2002 ACT-Europe                 --
--                                                                   --
-- This library is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This library is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this library; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-- As a special exception, if other files instantiate generics from  --
-- this unit, or you link this unit with other files to produce an   --
-- executable, this  unit  does not  by itself cause  the resulting  --
-- executable to be covered by the GNU General Public License. This  --
-- exception does not however invalidate any other reasons why the   --
-- executable file  might be covered by the  GNU Public License.     --
-----------------------------------------------------------------------

with Glib.Values;     use Glib.Values;
with Gtkada.Handlers; use Gtkada.Handlers;
with Gtk.Tree_Model; use Gtk.Tree_Model;
with Glib.Object; use Glib.Object;

package body Gtkada.Smart_Tree_Store is

   procedure Row_Expanded_Callback
     (Widget : access GObject_Record'Class;
      Params : Glib.Values.GValues);
   --  Callback for the "row_expanded" signal.

   procedure Row_Collapsed_Callback
     (Widget : access GObject_Record'Class;
      Params : Glib.Values.GValues);
   --  Callback for the "row_collapsed" signal.

   procedure Row_Inserted_Callback
     (Widget : access GObject_Record'Class;
      Params : Glib.Values.GValues);
   --  Callback for the "row_inserted" signal.

   ---------------------------
   -- Row_Expanded_Callback --
   ---------------------------

   procedure Row_Expanded_Callback
     (Widget : access GObject_Record'Class;
      Params : Glib.Values.GValues)
   is
      Tree  : constant Smart_Tree := Smart_Tree (Widget);
      Iter  : Gtk_Tree_Iter;
      Path  : Gtk_Tree_Path;
      Dummy : Boolean;
      pragma Unreferenced (Dummy);
   begin
      Get_Tree_Iter (Nth (Params, 1), Iter);

      Set (Tree.Model, Iter, Tree.Expanded_State_Column, True);

      Iter := Children (Tree.Model, Iter);

      while Iter /= Null_Iter loop
         if Get_Boolean (Tree.Model, Iter, Tree.Expanded_State_Column) then
            Path := Get_Path (Tree.Model, Iter);
            Dummy := Expand_Row (Tree, Path, False);
            Path_Free (Path);
         end if;

         Next (Tree.Model, Iter);
      end loop;

   end Row_Expanded_Callback;

   ----------------------------
   -- Row_Collapsed_Callback --
   ----------------------------

   procedure Row_Collapsed_Callback
     (Widget : access GObject_Record'Class;
      Params : Glib.Values.GValues)
   is
      Tree : constant Smart_Tree := Smart_Tree (Widget);
      Iter : Gtk_Tree_Iter;
   begin
      Get_Tree_Iter (Nth (Params, 1), Iter);
      Set (Tree.Model, Iter, Tree.Expanded_State_Column, False);
   end Row_Collapsed_Callback;

   ---------------------------
   -- Row_Inserted_Callback --
   ---------------------------

   procedure Row_Inserted_Callback
     (Widget : access GObject_Record'Class;
      Params : Glib.Values.GValues)
   is
      Tree : constant Smart_Tree := Smart_Tree (Widget);
      Iter : Gtk_Tree_Iter;
   begin
      Get_Tree_Iter (Nth (Params, 2), Iter);
      Set (Tree.Model, Iter, Tree.Expanded_State_Column, False);
   end Row_Inserted_Callback;

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New
     (Widget       : out Smart_Tree;
      Column_Types : GType_Array) is
   begin
      Widget := new Smart_Tree_Record;
      Initialize (Widget, Column_Types);
   end Gtk_New;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Widget       : access Smart_Tree_Record'Class;
      Column_Types : GType_Array)
   is
      Real_Column_Types : GType_Array
        (Column_Types'First .. Column_Types'Last + 1);
   begin
      Real_Column_Types := Column_Types & (GType_Boolean);
      Widget.Expanded_State_Column := Gint (Real_Column_Types'Last);

      Gtk_New (Widget.Model, Real_Column_Types);
      Initialize (Gtk_Tree_View (Widget), Widget.Model);

      Gtkada.Handlers.Object_Callback.Object_Connect
        (Widget,
         "row_expanded",
         Row_Expanded_Callback'Access,
         Widget,
         After => True);

      Gtkada.Handlers.Object_Callback.Object_Connect
        (Widget,
         "row_collapsed",
         Row_Collapsed_Callback'Access,
         Widget,
         After => True);

      --  Consider any newly inserted row as a collapsed row,
      --  set the flag accordingly.

      Gtkada.Handlers.Object_Callback.Object_Connect
        (Widget.Model,
         "row_inserted",
         Row_Inserted_Callback'Access,
         Widget,
         After => True);
   end Initialize;

end Gtkada.Smart_Tree_Store;
