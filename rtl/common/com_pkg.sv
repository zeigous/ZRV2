// shared stuff
package com_pkg;
    typedef struct packed {
        logic [63:0] address;
        logic valid;
        logic jump;
        logic taken;
        logic prediction;
    } flush_t;
endpackage
