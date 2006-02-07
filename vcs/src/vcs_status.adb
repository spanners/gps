-----------------------------------------------------------------------
--                               G P S                               --
--                                                                   --
--                      Copyright (C) 2005-2006                      --
--                              AdaCore                              --
--                                                                   --
-- GPS is free  software;  you can redistribute it and/or modify  it --
-- under the terms of the GNU General Public License as published by --
-- the Free Software Foundation; either version 2 of the License, or --
-- (at your option) any later version.                               --
--                                                                   --
-- This program is  distributed in the hope that it will be  useful, --
-- but  WITHOUT ANY WARRANTY;  without even the  implied warranty of --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details. You should have received --
-- a copy of the GNU General Public License along with this program; --
-- if not,  write to the  Free Software Foundation, Inc.,  59 Temple --
-- Place - Suite 330, Boston, MA 02111-1307, USA.                    --
-----------------------------------------------------------------------

with VCS_View; use VCS_View;

package body VCS_Status is

   function Copy (X : Line_Record) return Line_Record;
   --  Return a deep copy of X

   -----------------
   -- Clear_Cache --
   -----------------

   procedure Clear_Cache (Cache : Status_Cache) is
   begin
      Status_Hash.Reset (Cache.T.all);
   end Clear_Cache;

   ----------
   -- Copy --
   ----------

   function Copy (X : Line_Record) return Line_Record is
   begin
      return (Copy_File_Status (X.Status), X.Log);
   end Copy;

   ----------
   -- Free --
   ----------

   procedure Free (X : in out Line_Record) is
   begin
      Free (X.Status);
   end Free;

   ---------------
   -- Get_Cache --
   ---------------

   function Get_Cache
     (Cache : Status_Cache;
      File  : VFS.Virtual_File) return Line_Record is
   begin
      return Status_Hash.Get (Cache.T.all, File);
   end Get_Cache;

   ----------
   -- Hash --
   ----------

   function Hash (F : Virtual_File) return Header_Num is
      function Hash is new HTables.Hash (Header_Num);
   begin
      return Hash (File_Key (F));
   end Hash;

   ---------------
   -- Set_Cache --
   ---------------

   procedure Set_Cache
     (Cache  : Status_Cache;
      File   : VFS.Virtual_File;
      Status : in out Line_Record) is
   begin
      Status := Copy (Status);
      Status_Hash.Set (Cache.T.all, File, Status);
   end Set_Cache;

   ----------------
   -- Has_Status --
   ----------------

   function Has_Status
     (Cache  : Status_Cache;
      File   : VFS.Virtual_File;
      Ref    : VCS_Access;
      Status : Status_Id) return Boolean
   is
      S : constant File_Status := Get_File_Status (Ref, Status);
      L : constant Line_Record := Status_Hash.Get (Cache.T.all, File);
   begin
      if L /= No_Data
        and then L.Status.Status.Stock_Id.all = S.Stock_Id.all
      then
         return True;
      else
         return False;
      end if;
   end Has_Status;

end VCS_Status;
