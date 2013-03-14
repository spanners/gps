------------------------------------------------------------------------------
--                                  G P S                                   --
--                                                                          --
--                     Copyright (C) 2012-2013, AdaCore                     --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.  You should have  received  a copy of the GNU --
-- General  Public  License  distributed  with  this  software;   see  file --
-- COPYING3.  If not, go to http://www.gnu.org/licenses for a complete copy --
-- of the license.                                                          --
------------------------------------------------------------------------------

--  Declare parser to collect builder output.

with Ada.Strings.Unbounded;            use Ada.Strings.Unbounded;
with Build_Command_Utils;              use Build_Command_Utils;
with GPS.Kernel.Tools_Output;          use GPS.Kernel.Tools_Output;

package Build_Command_Manager.Build_Output_Collectors is

   type Build_Output_Collector is new Tools_Output_Parser with private;

   overriding procedure Parse_Standard_Output
     (Self : not null access Build_Output_Collector;
      Item : String;
      Command : Command_Access);

   type Output_Parser_Fabric is
     new GPS.Kernel.Tools_Output.Output_Parser_Fabric with private;

   procedure Set
     (Self       : access Output_Parser_Fabric;
      Builder    : Builder_Context;
      Target     : String;
      Shadow     : Boolean;
      Background : Boolean);

   overriding function Create
     (Self  : access Output_Parser_Fabric;
      Child : Tools_Output_Parser_Access)
      return Tools_Output_Parser_Access;
   --  Create new parser to collect builder output for Target.
   --  Collected output is then available with function
   --  Builder_Facility_Module.Get_Build_Output

private

   type Output_Parser_Fabric is
     new GPS.Kernel.Tools_Output.Output_Parser_Fabric with record
      Builder    : Builder_Context;
      Target     : Unbounded_String;
      Shadow     : Boolean;
      Background : Boolean;
   end record;

   type Build_Output_Collector is new Tools_Output_Parser with record
      Builder    : Builder_Context;
      Target     : Unbounded_String;
      Shadow     : Boolean;
      Background : Boolean;
   end record;

end Build_Command_Manager.Build_Output_Collectors;
