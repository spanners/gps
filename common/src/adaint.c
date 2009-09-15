/*********************************************************************
 *                               G P S                               *
 *                                                                   *
 *                      Copyright (C) 2009, AdaCore                  *
 *                                                                   *
 * GPS is free  software;  you can redistribute it and/or modify  it *
 * under the terms of the GNU General Public License as published by *
 * the Free Software Foundation; either version 2 of the License, or *
 * (at your option) any later version.                               *
 *                                                                   *
 * This program is  distributed in the hope that it will be  useful, *
 * but  WITHOUT ANY WARRANTY;  without even the  implied warranty of *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU *
 * General Public License for more details. You should have received *
 * a copy of the GNU General Public License along with this program; *
 * if not,  write to the  Free Software Foundation, Inc.,  59 Temple *
 * Place - Suite 330, Boston, MA 02111-1307, USA.                    *
 *********************************************************************/

/* Dummy version of adaint.c (needed by osint.adb) */

/* Type corresponding to GNAT.OS_Lib.OS_Time */
#if defined (_WIN64)
typedef long long OS_Time;
#else
typedef long OS_Time;
#endif

int __gnat_is_writable_file_attr (char* name, void* attr) {
  return __gnat_is_writable_file (name);
}

int __gnat_is_symbolic_link_attr (char* name, void* attr) {
   return __gnat_is_symbolic_link (name);
}

int __gnat_is_regular_file_attr (char* name, void* attr) {
   return __gnat_is_regular_file (name);
}

int __gnat_is_readable_file_attr (char* name, void* attr) {
   return __gnat_is_readable_file (name);
}

int __gnat_is_executable_file_attr (char* name, void* attr) {
   return __gnat_is_executable_file (name);
}

int __gnat_is_directory_attr (char* name, void* attr) {
   return __gnat_is_directory (name);
}

OS_Time __gnat_file_time_name_attr (char* name, void* attr) {
   return __gnat_file_time_name (name);
}

long __gnat_file_length_attr (int fd, char* name, void* attr) {
   if (fd != -1) {
      return __gnat_file_length (fd);
   } else {
      return __gnat_named_file_length (name);
   }
}

const int size_of_file_attributes = 0;

void reset_attributes (void* attr) {
   /* nothing to do */
}


