"""
This test checks that the client-side of the textDocument/signatureHelp request
works fine in GNAT Studio.
"""

import GPS
from gs_utils.internal.utils import *


EXPECTED_SIGNATURE = "do_something(int a, int b) -> void"
EXPECTED_MARKUP = "do_something(int a, int b, <b>int c</b>, int d) -> void"
EXPECTED_COMMENT = "This is another comment"


@run_test_driver
def run_test():
    # Open my_class.hh to make sure that clangd indexes it
    GPS.EditorBuffer.get(GPS.File("my_class.hh"))

    # Open main.cpp
    buf = GPS.EditorBuffer.get(GPS.File("main.cpp"))
    view = buf.current_view()
    view.goto(buf.at(12, 1).end_of_line())
    yield wait_idle()

    # Trigger the signatureHelp request by typing '('
    send_key_event(ord('('))
    yield hook('language_server_response_processed')

    signature_help_window = get_widget_by_name("signature-help-window")
    labels = get_widgets_by_type(Gtk.Label, signature_help_window)

    # Verify that all the label contents are correct
    gps_assert(labels[0].get_text(), "1/2",
               "The selector label text is not correct")
    gps_assert(labels[1].get_text(), EXPECTED_SIGNATURE,
               "The active signature label text is not correct")
    gps_assert(labels[2].get_text().strip(), EXPECTED_COMMENT,
               "The documentation label text is not correct")

    # Provide 3 paramters: only one 'do_something' signature should match
    # the provided parameters, so the selector label should be hidden
    buf.insert("3, 4")
    send_key_event(ord(","))
    yield hook('language_server_response_processed')
    yield wait_idle()

    gps_assert(labels[0].is_visible(), False,
               "The selector should not be visible")

    # Verify that the active parameter is bold
    gps_assert(labels[1].get_label(), EXPECTED_MARKUP,
               "The active paramer is not bold ")
