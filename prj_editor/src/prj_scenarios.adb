-----------------------------------------------------------------------
--                                                                   --
--                     Copyright (C) 2001                            --
--                          ACT-Europe                               --
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

with GNAT.Spitbol;
with Prj_API;       use Prj_API;

with Types;         use Types;
with Prj.Tree;      use Prj.Tree;
with Stringt;       use Stringt;
with Namet;         use Namet;

package body Prj_Scenarios is

   Scenario_Attribute_Name : constant String := "scenario";
   --  Name of the attribute used to store the name of the current
   --  configuration.

   use Name_Htables;

   function Build_Key (Values : String_Id_Array) return String;
   --  Return the key to use in the htable for a given set of values.

   ---------------
   -- Build_Key --
   ---------------

   function Build_Key (Values : String_Id_Array) return String is
      S : String (1 .. 1024);
      Index : Natural := S'First;
   begin
      for V in Values'Range loop
         pragma Assert (Values (V) /= No_String);

         declare
            T : constant String := Positive'Image (V) & "="
              & String_Id'Image (Values (V) - No_String) & ",";
         begin
            S (Index .. Index + T'Length - 1) := T;
            Index := Index + T'Length - 1;
         end;
      end loop;
      return S (S'First .. Index - 1);
   end Build_Key;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Manager : in out Scenario_Manager;
      Variables : Prj_API.Project_Node_Array)
   is
   begin
      Free (Manager.Variables);
      Clear (Manager.Names);

      Manager.Variables := new Project_Node_Array' (Variables);
   end Initialize;

   ------------------------
   -- Get_Scenario_Names --
   ------------------------

   function Get_Scenario_Names
     (Manager : Scenario_Manager;
      Values  : String_Id_Array)
      return String_Id_Array
   is
      Num : Positive := 1;
   begin
      --  Evaluate the number of possible scenarios that match values
      for V in Values'Range loop
         if Values (V) = No_String then
            Num := Num * Typed_Values_Count (Manager.Variables (V));
         end if;
      end loop;

      if Num = 1 then
         return (1 => Get (Manager.Names, Build_Key (Values)));

      else
         declare
            Output : String_Id_Array (1 .. Num);
            Val    : String_Id_Array := Values;
            Nodes  : Project_Node_Array (Values'Range) :=
              (others => Empty_Node);
            Index  : Natural := Output'First;
            Var_Index : Integer := Nodes'First;
         begin
            Main_Loop :
            loop
               --  Reinitialize all the lists that need to be reinitialized

               while Var_Index <= Nodes'Last loop
                  if Values (Var_Index) = No_String
                    and then Nodes (Var_Index) = Empty_Node
                  then
                     Nodes (Var_Index) := First_Literal_String
                       (String_Type_Of (Manager.Variables (Var_Index)));
                     Val (Var_Index) := String_Value_Of (Nodes (Var_Index));
                  end if;

                  Var_Index := Var_Index + 1;
               end loop;

               --  Output the current status

               Output (Index) := Get (Manager.Names, Build_Key (Val));
               Index := Index + 1;
               Var_Index := Var_Index - 1;

               --  Move the the next value

               loop
                  if Values (Var_Index) = No_String then
                     Nodes (Var_Index) :=
                       Next_Literal_String (Nodes (Var_Index));
                     exit when Nodes (Var_Index) /= Empty_Node;
                  end if;
                  Var_Index := Var_Index - 1;
                  exit Main_Loop when Var_Index < Nodes'First;
               end loop;

               Val (Var_Index) := String_Value_Of (Nodes (Var_Index));
               Var_Index := Var_Index + 1;
            end loop Main_Loop;

            return Output;
         end;
      end if;
   end Get_Scenario_Names;

   -----------------------
   -- Set_Scenario_Name --
   -----------------------

   procedure Set_Scenario_Name
     (Manager : in out Scenario_Manager;
      Values  : String_Id_Array;
      Name    : String) is
   begin
      Start_String;
      Store_String_Chars (Name);
      Set (Manager.Names, Build_Key (Values), End_String);
   end Set_Scenario_Name;

   --------------------
   -- Variable_Index --
   --------------------

   function Variable_Index
     (Manager           : Scenario_Manager;
      Env_Variable_Name : Types.String_Id)
      return Natural is
   begin
      pragma Assert (Manager.Variables /= null);

      for V in Manager.Variables'Range loop
         if String_Equal
           (External_Reference_Of (Manager.Variables (V)), Env_Variable_Name)
         then
            return V;
         end if;
      end loop;
      return 0;
   end Variable_Index;

   ------------------------
   -- Append_Declaration --
   ------------------------

   procedure Append_Declaration
     (Manager : Scenario_Manager; Prj_Or_Pkg : Project_Node_Id)
   is
      Last_Decl_Item, Item : Project_Node_Id;
      Var_Values : Project_Node_Array (Manager.Variables'Range) :=
        (others => Empty_Node);
      Cases : Project_Node_Array (Manager.Variables'Range);
      Strings : String_Id_Array (Manager.Variables'Range);
      Index : Natural := Var_Values'First;
      Str : String_Id;

   begin
      pragma Assert (Manager.Variables /= null);
      pragma Assert (Kind_Of (Prj_Or_Pkg) = N_Project
                     or else Kind_Of (Prj_Or_Pkg) = N_Package_Declaration);

      --  Create the types and variables. Note that some of the nodes are
      --  shared, including the list of possible values in the types.

      for Var in Manager.Variables'Range loop
         Item := Get_Or_Create_Type
           (Prj_Or_Pkg => Prj_Or_Pkg,
            Name       => Get_Name_String
              (Name_Of (String_Type_Of (Manager.Variables (Var)))));
         Set_First_Literal_String
           (Item,
            First_Literal_String (String_Type_Of (Manager.Variables (Var))));

         Item := Get_Or_Create_Typed_Variable
           (Prj_Or_Pkg => Prj_Or_Pkg,
            Name => Get_Name_String (Name_Of (Manager.Variables (Var))),
            Typ  => Item);
         Set_Expression_Of (Item, Expression_Of (Manager.Variables (Var)));
      end loop;

      --  Find the last declarative item, so that we can add the case statement
      --  after the declaration of variables.

      case Kind_Of (Prj_Or_Pkg) is
         when N_Project =>
            Last_Decl_Item := First_Declarative_Item_Of
              (Project_Declaration_Of (Prj_Or_Pkg));
         when N_Package_Declaration =>
            Last_Decl_Item := Prj_Or_Pkg;
         when others =>
            null;
      end case;

      while Next_Declarative_Item (Last_Decl_Item) /= Empty_Node loop
         Last_Decl_Item := Next_Declarative_Item (Last_Decl_Item);
      end loop;

      Cases (Cases'First) := Empty_Node;

      --  Create the nested case statement that sets all the possible names.

      Main_Loop :
      loop
         --  Open all the case statements that were closed (or not yet open)

         while Index <= Var_Values'Last loop
            --  Set the default value for the variable if it is not set yet
            if Var_Values (Index) = Empty_Node then
               Var_Values (Index) := First_Literal_String
                 (String_Type_Of (Manager.Variables (Index)));
               Strings (Index) := String_Value_Of (Var_Values (Index));
            end if;

            --  The declarative item
            Item := Default_Project_Node (N_Declarative_Item);
            if Index = Var_Values'First then
               Set_Next_Declarative_Item (Last_Decl_Item, Item);
               Last_Decl_Item := Item;
            else
               Set_First_Declarative_Item_Of
                 (First_Case_Item_Of (Cases (Index - 1)), Item);
            end if;

            --  "case " & Var & " is", and first "when" statement
            Cases (Index) := Default_Project_Node (N_Case_Construction);
            Set_Current_Item_Node (Item, Cases (Index));
            Set_Case_Variable_Reference_Of
              (Cases (Index),
               Create_Variable_Reference (Manager.Variables (Index)));
            Create_Case_Item
              (Cases (Index), String_Value_Of (Var_Values (Index)));

            Index := Index + 1;
         end loop;

         Index := Index - 1;

         --  "For Scenario use " & Name

         Str := Get (Manager.Names, Build_Key (Strings));

         if Str /= No_String then
            Set_Expression_Of
              (Get_Or_Create_Attribute
               (First_Case_Item_Of (Cases (Index)),
                Scenario_Attribute_Name, Kind => Prj.Single),
               String_As_Expression (Str));
         end if;

         --  Move to the next value in case

         loop
            Var_Values (Index) := Next_Literal_String (Var_Values (Index));

            if Var_Values (Index) = Empty_Node then
               Index := Index - 1;
               exit Main_Loop when Index = 0;
            else
               Strings (Index) := String_Value_Of (Var_Values (Index));
               Create_Case_Item (Cases (Index), Strings (Index));
               exit;
            end if;
         end loop;

         Index := Index + 1;
      end loop Main_Loop;
   end Append_Declaration;

end Prj_Scenarios;

