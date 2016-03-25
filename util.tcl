proc K { x y } { set x }

proc fread { fname } {
    K [read [set fp [open $fname]]] [close $fp]
}

proc fwritelines { lines fname } {
    set fp [open $fname w]
    foreach line $lines { puts $fp $line }
    close $fp
}

proc getlines { fname } {
    set data [fread $fname]
    if { [llength $data] > 1 } {
        return [lrange [split $data \n] 0 end-1]
    } else {
        return data
    }
}

proc member { item list } { expr { [lsearch $list $item] != -1 } }

proc ::tcl::dict::read { fname } {
    try            { ::set x [fread $fname]
    } on error msg { ::set x {} }

    return $x
}

proc ::tcl::dict::write { dictval fname } {
    ::set fp [open $fname w]
    try {
        puts $fp $dictval
        close $fp
        return 0
    } on error msg { close $fp; return -1 }

}

namespace ensemble configure dict -map [dict merge [namespace ensemble configure dict -map] {read ::tcl::dict::read write ::tcl::dict::write}]

# indent str i spaces
proc indent { i str } { return "[string repeat { } $i]$str" }

proc pdict { dname dval {i 0}} {
    puts [indent $i $dname]
    puts [indent $i [string repeat - [string length $dname]]]
    foreach k [dict keys $dval] {
        if { $k eq "list" } {

            set list [dict get $dval $k]
            for {set j 1} {$j <= [llength $list]} {incr j} {
                puts [indent $i "$j. [lindex $list $j-1]"]
            }
        } else {
            pdict $k [dict get $dval $k] [expr {$i+4}]
        }
    }
}

proc ::tcl::dict::get? {args} {
    try {                ::set x [dict get {*}$args]
    } on error message { ::set x {} }

    return $x
}; #JBR

 namespace ensemble configure dict -map [dict merge [namespace ensemble configure dict -map] {get? ::tcl::dict::get?}]
