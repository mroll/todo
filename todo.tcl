#!/usr/bin/env tclsh8.6

# what you should be able to do:
#   - make a list               ✓
#   - add items to a list       ✓
#   - view a list by name       ✓
#   - remove items from a list  ✓
#   - move item's position      ✓
#   - edit a list item
#

source util.tcl


namespace eval todo {
    variable current_user
    variable userdir

    proc usage { } {
        puts [subst -nocommands {todo [-s list] | [-a list item] | [-n name]}]
    }

    proc setup { args } {
        set argvals [lindex $args 0]
        set vars    [lrange $args 1 end]

        set delim [lsearch $argvals --]
        if { $delim != -1 } {
            # labels are used
            uplevel [list set labels  [lrange $argvals 0 $delim-1]]
        } else {
            # no labels; default section
            uplevel [list set labels  {}]
        }

        if { [llength $vars] == 1 } {
            uplevel [list set $vars [lrange $argvals $delim+1 end]]
        } else {
            for {set i 1} {$i <= [llength $vars]} {incr i} {
                uplevel [list set [lindex $vars $i-1] [lindex $argvals $delim+$i]]
            }
        }

    }

    # ex.
    #   todo add main march math -- integrate the two-body problem
    #
    proc add { listname args } {
        variable current_user
        variable userdir

        setup $args newitem
        set listfile $userdir/$current_user/$listname

        if { [file exists $listfile] } {
            set list [dict read $listfile]
        } else {
            set list {}
        }

        set prev [dict get? $list {*}$labels list]
        dict set list {*}$labels list [concat $prev [list $newitem]]

        dict write $list $listfile
    }

    proc rm { listname args } {
        variable current_user
        variable userdir

        setup $args i
        set listfile $userdir/$current_user/$listname

        if { [file exists $listfile] } {
            set list [dict read $listfile]
            set prev [dict get? $list {*}$labels list]

            dict set list {*}$labels list [lreplace $prev $i-1 $i-1]

            dict write $list $listfile
        } else {
            puts "Sorry, that list doesn't exist..."
        }

    }

    proc mv { listname args } {
        variable current_user
        variable userdir

        setup $args src dst
        incr src -1; incr dst -1

        set listfile $userdir/$current_user/$listname

        if { [file exists $listfile] } {
            set list [dict read $listfile]
            set prev [dict get? $list {*}$labels list]

            set tmp [lindex $prev $dst]
            lset prev $dst [lindex $prev $src]
            lset prev $src $tmp

            dict set list {*}$labels list $prev

            dict write $list $listfile
        } else {
            puts "Sorry, that list doesn't exist..."
        }
    }

    proc see { listname } {
        variable current_user
        variable userdir

        set listfile $userdir/$current_user/$listname

        if { [file exists $listfile] } {
            set list [dict read $listfile]

            pdict $listname $list
        } else {
            puts "Sorry, that list doesn't exist yet..."
        }
    }
}

proc main { argc argv } {
    if { $argc < 1 } {
        usage
    }

    set todo::userdir      /home/matt/.todo
    set todo::current_user matt

    set subcmd [lindex $argv 0]
    set args   [lrange $argv 1 end]

    todo::$subcmd {*}$args
}

main $argc $argv
