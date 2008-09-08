"""This file provides support for displaying Ada expanded code as generated by
   GNAT (-gnatDL switch), and jump to the corresponding line of code.
"""


import os, os.path, re, string, distutils.dep_util
import GPS

def create_dg (f, str):
  res=file (f, 'wb')
  first = str.find ("\n", str.find ("\n", str.find ("Source recreated from tree"))+1)+2

  if first > 2:
    last = str.find ("Source recreated from tree", first)
    res.write (str [first:last-1])

  res.close()

def edit_dg (dg, line):
  buf = GPS.EditorBuffer.get (GPS.File (dg))
  GPS.MDI.get_by_child (buf.current_view()).raise_window()
  loc = GPS.EditorLocation (buf, 1, 1)
  (frm, to) = loc.search ("^-- " + `line` + ":", regexp=True)
  if frm:
    buf.current_view().goto (frm.forward_line (1))

def on_exit (process, status, full_output):
  create_dg (process.dg, full_output)
  edit_dg (process.dg, process.line)

def show_gnatdg():
  """Show the .dg file of the current file"""
  GPS.MDI.save_all (False)
  context = GPS.current_context()
  file = context.file().name()
  line = context.location().line()
  objdir = context.project().object_dirs (False)[0]
  dg = os.path.join (objdir, os.path.basename (file)) + '.dg'

  if distutils.dep_util.newer (file, dg):
    gnatmake = GPS.Project.root().get_attribute_as_string ("compiler_command",
                 package="ide", index="ada")
    cmd = gnatmake + " -q -P" + GPS.Project.root().file().name() + \
          " -f -c -u -gnatcdx -gnatws -gnatGL " + file
    GPS.Console ("Messages").write ("Generating " + dg + "...")
    proc = GPS.Process (cmd, on_exit=on_exit)
    proc.dg = dg
    proc.line = line
  else:
    edit_dg (dg, line)

def on_gps_started (hook):
  GPS.parse_xml ("""<action name="show expanded code" category="Ada" output="none">
    <filter language="Ada" />
    <shell lang="python">expanded_code.show_gnatdg()</shell>
  </action>
  <contextual action="show expanded code" >
    <Title>Show expanded code</Title>
  </contextual>""")

GPS.Hook ("gps_started").add (on_gps_started)
