with Gtk.Window; use Gtk.Window;
with Gtk.Frame; use Gtk.Frame;
with Gtk.Box; use Gtk.Box;
with Gtk.Table; use Gtk.Table;
with Gtk.Label; use Gtk.Label;
with Gtk.Combo; use Gtk.Combo;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Tooltips; use Gtk.Tooltips;
with Gtk.Check_Button; use Gtk.Check_Button;
with Gtk.Button; use Gtk.Button;
package Vsearch_Pkg is

   type Vsearch_Record is new Gtk_Window_Record with record
      Search_Frame : Gtk_Frame;
      Vbox_Search : Gtk_Vbox;
      Table : Gtk_Table;
      Replace_Label : Gtk_Label;
      Search_For_Label : Gtk_Label;
      Search_In_Label : Gtk_Label;
      Files_Frame : Gtk_Frame;
      Files_Table : Gtk_Table;
      Files_Label : Gtk_Label;
      Directory_Label : Gtk_Label;
      Files_Combo : Gtk_Combo;
      Files_Entry : Gtk_Entry;
      Directory_Combo : Gtk_Combo;
      Directory_Entry : Gtk_Entry;
      Subdirs_Check : Gtk_Check_Button;
      Browse_Button : Gtk_Button;
      Replace_Combo : Gtk_Combo;
      Replace_Entry : Gtk_Entry;
      Context_Combo : Gtk_Combo;
      Context_Entry : Gtk_Entry;
      Buttons_Hbox : Gtk_Hbox;
      Options_Frame : Gtk_Frame;
      Options_Vbox : Gtk_Vbox;
      Scope_Hbox : Gtk_Hbox;
      Scope_Label : Gtk_Label;
      Scope_Combo : Gtk_Combo;
      Scope_Entry : Gtk_Entry;
      Search_All_Check : Gtk_Check_Button;
      Case_Check : Gtk_Check_Button;
      Whole_Word_Check : Gtk_Check_Button;
      Regexp_Check : Gtk_Check_Button;
      Pattern_Combo : Gtk_Combo;
      Pattern_Entry : Gtk_Entry;
   end record;
   type Vsearch_Access is access all Vsearch_Record'Class;

   procedure Gtk_New (Vsearch : out Vsearch_Access);
   procedure Initialize (Vsearch : access Vsearch_Record'Class);

end Vsearch_Pkg;
