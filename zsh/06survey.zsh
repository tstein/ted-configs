function survey() {
    # extract text [key]
    #   Return everything after the first : in text, chomped. If key is given,
    #   grep for key first.
    function extract() {
        local line=$1
        if [[ $# == 2 ]]; then
            local key=$2
            line=`print $line | grep $key`
        fi
        print $line | cut -d : -f 2- | chomp
    }

    local os release model cpus mem swap

    local os=`uname -s`
    if [[ $os == 'Darwin' ]]; then
        os='macOS'
    fi

    case $os in
        'Linux')
            if [[ -e /etc/os-release ]]; then
                source /etc/os-release
                release=$PRETTY_NAME
            else
                release='unknown'
            fi

            local cpu_lines=`grep 'model name' /proc/cpuinfo`
            local cpu_line=`print $cpu_lines | head -n 1`
            local cpu_count=`echo $cpu_lines | wc -l`
            local cpu=`extract $cpu_line | sed 's/(R)//g'`
            cpus="${cpu_count}x $cpu"

            local meminfo=`cat /proc/meminfo`
            local mem_kb=`extract $meminfo 'MemTotal' | sed 's/ kB//'`
            mem="$(($mem_kb / 1024)) MB"

            local swap_kb=`extract $meminfo 'SwapTotal' | sed 's/ kB//'`
            if [[ $swap_kb != '0' ]]; then
                swap="$(($swap_kb / 1024)) MB"
            fi
            ;;

        'macOS')
            release=`sw_vers -productVersion`
            local sp_hardware=`system_profiler SPHardwareDataType`

            model=`extract $sp_hardware 'Model Identifier'`

            local cpu=`extract $sp_hardware 'Processor Name'`
            local cpu_speed=`extract $sp_hardware 'Processor Speed'`
            local cpu_count=`extract $sp_hardware 'Total Number of Cores'`
            cpus="${cpu_count}x $cpu @ $cpu_speed"

            mem=`extract $sp_hardware 'Memory'`
            ;;
    esac

    print "OS:          $os"
    print "Release:     $release"
    if [[ $model != "" ]]; then
        print "Model:       $model"
    fi
    print "CPUs:        $cpus"
    print "RAM:         $mem"
    if [[ $swap != "" ]]; then
        print "Swap:        $swap"
    fi

}
